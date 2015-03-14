_ = require 'lodash'
async = require 'async'
ExecutedModuleFinder = require './executed_module_finder'
RequiredModuleFinder = require './required_module_finder'


class UsedModuleFinder

  constructor: ({@dir, ignoreFiles}) ->
    @executedModuleFinder = new ExecutedModuleFinder {@dir}
    @requiredModuleFinder = new RequiredModuleFinder {@dir, ignoreFiles}


  find: (done) ->
    async.parallel [
      (taskDone) => @requiredModuleFinder.find taskDone
      (taskDone) => @executedModuleFinder.find taskDone
    ], (err, results) =>
      if err then return done err
      done null, @normalizeModules(results)


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
