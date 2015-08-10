_ = require 'lodash'
ExecutedModuleFinder = require './executed_module_finder'
Promise = require 'bluebird'
RequiredModuleFinder = require './required_module_finder'


class UsedModuleFinder

  constructor: ({ignoreFilePatterns}) ->
    @executedModuleFinder = new ExecutedModuleFinder
    @requiredModuleFinder = new RequiredModuleFinder {ignoreFilePatterns}


  find: (dir) =>
    Promise.all [@requiredModuleFinder.find(dir), @executedModuleFinder.find(dir)]
      .then @normalizeModules


  normalizeModules: (modules...) ->
    result = {}
    for {name, files, scripts} in _.flattenDeep(modules)
      if result[name]
        result[name].files = result[name].files.concat files if files
        result[name].scripts = result[name].scripts.concat scripts if scripts
      else
        result[name] = {name, files: files ? [], scripts: scripts ? []}

    moduleData for _, moduleData of result


module.exports = UsedModuleFinder
