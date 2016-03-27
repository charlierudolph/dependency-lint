_ = require 'lodash'
async = require 'async'
asyncHandlers = require 'async-handlers'
ExecutedModuleFinder = require './executed_module_finder'
RequiredModuleFinder = require './required_module_finder'


class UsedModuleFinder

  constructor: (config) ->
    @executedModuleFinder = new ExecutedModuleFinder
    @requiredModuleFinder = new RequiredModuleFinder config.requiredModules


  find: ({dir, packageJson}, done) =>
    async.parallel [
      (next) => @requiredModuleFinder.find dir, next
      (next) => @executedModuleFinder.find {dir, packageJson}, next
    ], asyncHandlers.transform(@normalizeModules, done)


  normalizeModules: (modules...) ->
    result = {}
    for {name, file, script} in _.flattenDeep(modules)
      result[name] = {name, files: [], scripts: []} unless result[name]
      result[name].files.push file if file
      result[name].scripts.push script if script
    _.values result


module.exports = UsedModuleFinder
