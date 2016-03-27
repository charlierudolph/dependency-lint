_ = require 'lodash'
async = require 'async'
asyncHandlers = require 'async-handlers'
fs = require 'fs'
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
        result.push moduleName if script.match(executable) and moduleName not in result
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
    binPath = path.join dir, 'node_modules', '.bin'
    async.auto {
      executables: (next) ->
        fs.access binPath, (err) ->
          if err then return done null, []
          fs.readdir binPath, next

      links: ['executables', (next, {executables}) ->
        files = executables.map (file) -> path.join binPath, file
        async.map files, fs.readlink, next
      ]
    }, asyncHandlers.transform(@parseModuleExecutables, done)


  parseModuleExecutables: ({executables, links}) ->
    result = {}
    links.forEach (link, index) ->
      name = ModuleNameParser.stripSubpath path.relative('..', link)
      result[name] = [] unless result[name]
      result[name].push path.basename executables[index]
    result


  readShellScripts: (dir, done) ->
    glob @shellScripts.root, {cwd: dir, ignore: @shellScripts.ignore}, (err, filePaths) ->
      if err then return done err
      iterator = (filePath, next) ->
        fs.readFile path.join(dir, filePath), encoding: 'utf8', next
      zip = (fileContents) -> _.zipObject filePaths, fileContents
      async.map filePaths, iterator, asyncHandlers.transform(zip, done)


module.exports = ExecutedModulesFinder
