_ = require 'lodash'
fsExtra = require 'fs-extra'
ModuleNameParser = require './module_name_parser'
path = require 'path'
Promise = require 'bluebird'


{coroutine} = Promise
glob = Promise.promisify require('glob')
readFile = Promise.promisify fsExtra.readFile
readJson = Promise.promisify fsExtra.readJson


class ExecutedModulesFinder

  constructor: ({@shellScripts}) ->


  find: coroutine ({dir, packageJson}) ->
    [moduleExecutables, shellScripts] = yield Promise.all [
      @getModuleExecutables(dir)
      @readShellScripts(dir)
    ]
    packageJsonScripts = packageJson.scripts or {}
    @findModuleExecutableUsage {moduleExecutables, packageJsonScripts, shellScripts}


  findInScript: (script, moduleExecutables) ->
    result = []
    for name, executables of moduleExecutables
      for executable in executables
        continue if ModuleNameParser.isGlobalExecutable executable
        result.push name if script.match("\\b#{executable}\\b") and name not in result
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


  getModuleExecutables: coroutine (dir) ->
    nodeModulesPath = path.join dir, 'node_modules'
    files = yield glob "#{nodeModulesPath}/{*,*/*}/package.json"
    _.fromPairs yield Promise.map files, @getModuleExecutablesPair


  getModuleExecutablesPair: coroutine (packageJsonPath) ->
    packageJson = yield readJson packageJsonPath
    executables = if _.isString packageJson.bin
      [packageJson.name]
    else if _.isObject packageJson.bin
      _.keys packageJson.bin
    else
      []
    [packageJson.name, executables]


  readShellScripts: coroutine (dir, done) ->
    filePaths = yield glob @shellScripts.root, {cwd: dir, ignore: @shellScripts.ignore}
    fileMapping = _.fromPairs filePaths.map (filePath) ->
      fileContentPromise = readFile path.join(dir, filePath), 'utf8'
      [filePath, fileContentPromise]
    yield Promise.props fileMapping


module.exports = ExecutedModulesFinder
