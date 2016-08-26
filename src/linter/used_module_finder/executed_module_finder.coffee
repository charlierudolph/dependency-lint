_ = require 'lodash'
async = require 'async'
asyncHandlers = require 'async-handlers'
fs = require 'fs'
fsExtra = require 'fs-extra'
glob = require 'glob'
ModuleNameParser = require './module_name_parser'
path = require 'path'


class ExecutedModulesFinder

  constructor: ({@shellScripts}) ->


  find: ({dir, packageJson}, done) ->
    packageJsonScripts = packageJson.scripts or {}
    getUsage = ([moduleExecutables, shellScripts]) =>
      @findModuleExecutableUsage {moduleExecutables, packageJsonScripts, shellScripts}
    async.parallel [
      (cb) => @getModuleExecutables dir, cb
      (cb) => @readShellScripts dir, cb
    ], asyncHandlers.transform(getUsage, done)


  findInScript: (script, moduleExecutables) ->
    result = []
    for moduleName, executables of moduleExecutables
      for executable in executables
        continue if ModuleNameParser.isGlobalExecutable executable
        result.push moduleName if script.match("\\b#{executable}\\b") and moduleName not in result
    result


  findModuleExecutableUsage: ({moduleExecutables, packageJsonScripts, shellScripts}) =>
    result = []
    for scriptName, script of packageJsonScripts
      for moduleName in @findInScript script, moduleExecutables
        result.push {name: moduleName, script: scriptName}
    for filePath, fileContent of shellScripts
      for moduleName in @findInScript fileContent, moduleExecutables
        result.push {name: moduleName, file: filePath}
    result


  getModuleExecutables: (dir, done) ->
    nodeModulesPath = path.join dir, 'node_modules'
    glob "#{nodeModulesPath}/{*,*/*}/package.json", (err, files) ->
      if err then return done err
      iterator = (file, cb) ->
        fsExtra.readJson file, (err, packageJson) ->
          if err then return cb err
          executables = if _.isString packageJson.bin
            [packageJson.name]
          else if _.isObject packageJson.bin
            _.keys packageJson.bin
          else
            []
          cb null, [packageJson.name, executables]
      async.map files, iterator, asyncHandlers.transform(_.fromPairs, done)


  readShellScripts: (dir, done) ->
    glob @shellScripts.root, {cwd: dir, ignore: @shellScripts.ignore}, (err, filePaths) ->
      if err then return done err
      iterator = (filePath, next) ->
        fs.readFile path.join(dir, filePath), encoding: 'utf8', next
      zip = (fileContents) -> _.zipObject filePaths, fileContents
      async.map filePaths, iterator, asyncHandlers.transform(zip, done)


module.exports = ExecutedModulesFinder
