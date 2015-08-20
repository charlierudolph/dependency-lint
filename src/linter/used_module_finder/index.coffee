_ = require 'lodash'
async = require 'async'
asyncHandlers = require 'async-handlers'
ExecutedModuleFinder = require './executed_module_finder'
RequiredModuleFinder = require './required_module_finder'


class UsedModuleFinder

  constructor: ({ignoreFilePatterns}) ->
    @executedModuleFinder = new ExecutedModuleFinder
    @requiredModuleFinder = new RequiredModuleFinder {ignoreFilePatterns}


  find: (dir, done) =>
    async.parallel [
      (next) => @requiredModuleFinder.find dir, next
      (next) => @executedModuleFinder.find dir, next
    ], asyncHandlers.transform(@normalizeModules, done)


  normalizeModules: (modules...) ->
    result = {}
    for {name, file, script} in _.flattenDeep(modules)
      result[name] or= {name, files: [], scripts: []}
      result[name].files.push file if file
      result[name].scripts.push script if script
    _.values result


module.exports = UsedModuleFinder
