async = require 'async'
asyncHandlers = require 'async-handlers'
DependencyLinter = require './dependency_linter'
ListedModuleFinder = require './listed_module_finder'
UsedModuleFinder = require './used_module_finder'


class Linter

  constructor: (@dir, {allowUnused, devFilePatterns, devScripts, ignoreFilePatterns}) ->
    @dependencyLinter = new DependencyLinter {allowUnused, devFilePatterns, devScripts}
    @listedModuleFinder = new ListedModuleFinder {@dir}
    @usedModuleFinder = new UsedModuleFinder {@dir, ignoreFilePatterns}


  lint: (done) ->
    async.parallel {
      listedModules: @listedModuleFinder.find
      usedModules: @usedModuleFinder.find
    }, asyncHandlers.transform(@dependencyLinter.lint, done)


module.exports = Linter
