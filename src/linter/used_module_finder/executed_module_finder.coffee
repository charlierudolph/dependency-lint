class ExecutedModulesFinder

  constructor: ({@dir}) ->
    _ = require 'lodash'
    path = require 'path'
    {@scripts, dependencies, devDependencies} = require path.join(@dir, 'package.json')
    @scripts ?= {}
    @modulesListed = _.keys(dependencies).concat _.keys(devDependencies)


  find: (done) ->
    async = require 'async'
    asyncHandlers = require 'async-handlers'
    async.auto {
      packageJsons: @getModulePackageJsons
      moduleExecutables: ['packageJsons', (next, {packageJsons}) =>
        next null, @getModuleExecutables(packageJsons)
      ]
      ensureInstalled: ['moduleExecutables', (next, {moduleExecutables}) =>
        @ensureAllModulesInstalled moduleExecutables, next
      ]
      formattedExecutables: ['moduleExecutables', (next, {moduleExecutables}) =>
        next null, @parseModuleExecutables(moduleExecutables)
      ]
    }, asyncHandlers.extract('formattedExecutables', done)


  ensureAllModulesInstalled: (moduleExecutables, done) ->
    _ = require 'lodash'
    modulesNotInstalled = _.difference @listedModules, _.keys(moduleExecutables)
    if modulesNotInstalled.length is 0
      done()
    else
      done new Error """
        The following modules are listed in your `package.json` but are not installed.
          #{modulesNotInstalled.join '\n  '}
        All modules need to be installed to properly check for the usage of a module's executables.
        """


  findInScript: (script, moduleExecutables) ->
    result = []
    for moduleName, executables of moduleExecutables
      for executable in executables
        result.push moduleName if script.match(executable) and moduleName not in result
    ModuleFilterer = require './module_filterer'
    result = ModuleFilterer.filterExecutedModules result
    result


  getModulePackageJsons: (done) =>
    patterns = [
      "#{@dir}/node_modules/*/package.json"
      "#{@dir}/node_modules/*/*/package.json" # scoped packages
    ]
    glob = require 'glob'
    async = require 'async'
    async.concat patterns, glob, done


  getModuleExecutables: (packageJsons) ->
    _ = require 'lodash'
    result = {}
    for packageJson in packageJsons
      {name, bin} = require packageJson
      result[name] = _.keys bin
    result


  parseModuleExecutables: (moduleExecutables) =>
    result = []
    for scriptName, script of @scripts
      for moduleName in @findInScript script, moduleExecutables
        result.push {name: moduleName, scripts: [scriptName]}
    result


module.exports = ExecutedModulesFinder
