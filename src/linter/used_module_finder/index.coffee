_ = require 'lodash'
ExecutedModuleFinder = require './executed_module_finder'
Promise = require 'bluebird'
RequiredModuleFinder = require './required_module_finder'


{coroutine} = Promise


class UsedModuleFinder

  constructor: (config) ->
    @executedModuleFinder = new ExecutedModuleFinder config.executedModules
    @requiredModuleFinder = new RequiredModuleFinder config.requiredModules


  find: coroutine ({dir, packageJson}) ->
    @normalizeModules yield Promise.all [
      @executedModuleFinder.find {dir, packageJson}
      @requiredModuleFinder.find dir
    ]


  normalizeModules: (modules...) ->
    result = {}
    for {name, file, script} in _.flattenDeep(modules)
      result[name] = {name, files: [], scripts: []} unless result[name]
      result[name].files.push file if file
      result[name].scripts.push script if script
    _.values result


module.exports = UsedModuleFinder
