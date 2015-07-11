class UsedModuleFinder

  constructor: ({@dir, @ignoreFilePatterns}) ->


  find: (done) =>
    async = require 'async'
    asyncHandlers = require 'async-handlers'
    handler = asyncHandlers.transform @normalizeModules, done
    async.parallel {
      executedModules: @getExecutedModules
      requiredModules: @getRequiredModules
    }, handler


  # Private
  getExecutedModules: (done) =>
    ExecutedModuleFinder = require './executed_module_finder'
    executedModuleFinder = new ExecutedModuleFinder {@dir}
    executedModuleFinder.find done

  # Private
  getRequiredModules: (done) =>
    RequiredModuleFinder = require './required_module_finder'
    requiredModuleFinder = new RequiredModuleFinder {@dir, @ignoreFilePatterns}
    requiredModuleFinder.find done


  # Private
  normalizeModules: ({executedModules, requiredModules}) ->
    result = {}
    for {name, files, scripts} in executedModules.concat requiredModules
      if result[name]
        result[name].files = result[name].files.concat files if files
        result[name].scripts = result[name].scripts.concat scripts if scripts
      else
        result[name] = {name, files: files ? [], scripts: scripts ? []}

    moduleData for _, moduleData of result


module.exports = UsedModuleFinder
