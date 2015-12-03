async = require 'async'
asyncHandlers = require 'async-handlers'
DependencyLinter = require './dependency_linter'
ListedModuleFinder = require './listed_module_finder'
UsedModuleFinder = require './used_module_finder'


class Linter

  constructor: ({allowUnused, devFilePatterns, devScripts, ignoreFilePatterns, stripLoaders}) ->
    @dependencyLinter = new DependencyLinter {allowUnused, devFilePatterns, devScripts}
    @listedModuleFinder = new ListedModuleFinder
    @usedModuleFinder = new UsedModuleFinder {ignoreFilePatterns, stripLoaders}


  lint: (dir, done) ->
    async.parallel {
      listedModules: (next) => @listedModuleFinder.find dir, next
      usedModules: (next) => @usedModuleFinder.find dir, next
    }, asyncHandlers.transform(@dependencyLinter.lint, done)


module.exports = Linter
