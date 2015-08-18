_ = require 'lodash'
ModuleFilterer = require './module_filterer'
Promise = require 'bluebird'
path = require 'path'

glob = Promise.promisify require('glob')


class ExecutedModulesFinder

  find: (dir) ->
    {scripts, dependencies, devDependencies} = require path.join(dir, 'package.json')
    scripts ?= {}
    modulesListed = _.keys(dependencies).concat _.keys(devDependencies)
    @getModulePackageJsons dir
      .then @getModuleExecutables
      .tap (moduleExecutables) => @ensureAllModulesInstalled {modulesListed, moduleExecutables}
      .then (moduleExecutables) => @parseModuleExecutables {moduleExecutables, scripts}


  ensureAllModulesInstalled: ({modulesListed, moduleExecutables}) ->
    modulesNotInstalled = _.difference modulesListed, _.keys(moduleExecutables)
    return if modulesNotInstalled.length is 0
    throw Error """
      The following modules are listed in your `package.json` but are not installed.
        #{modulesNotInstalled.join '\n  '}
      All modules need to be installed to properly check for the usage of a module's executables.
      """


  findInScript: (script, moduleExecutables) ->
    result = []
    for moduleName, executables of moduleExecutables
      for executable in executables
        result.push moduleName if script.match(executable) and moduleName not in result
    result = ModuleFilterer.filterExecutedModules result
    result


  getModulePackageJsons: (dir) ->
    patterns = [
      "#{dir}/node_modules/*/package.json"
      "#{dir}/node_modules/*/*/package.json" # scoped packages
    ]
    Promise.resolve patterns
      .map (pattern) -> glob pattern
      .then (files) -> _.flatten files


  getModuleExecutables: (packageJsons) ->
    result = {}
    for packageJson in packageJsons
      {name, bin} = require packageJson
      result[name] = _.keys bin
    result


  parseModuleExecutables: ({moduleExecutables, scripts}) =>
    result = []
    for scriptName, script of scripts
      for moduleName in @findInScript script, moduleExecutables
        result.push {name: moduleName, scripts: [scriptName]}
    result


module.exports = ExecutedModulesFinder
