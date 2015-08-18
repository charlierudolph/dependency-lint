DependencyLinter = require './dependency_linter'
ListedModuleFinder = require './listed_module_finder'
UsedModuleFinder = require './used_module_finder'
Promise = require 'bluebird'


class Linter

  constructor: ({allowUnused, devFilePatterns, devScripts, ignoreFilePatterns}) ->
    @dependencyLinter = new DependencyLinter {allowUnused, devFilePatterns, devScripts}
    @listedModuleFinder = new ListedModuleFinder
    @usedModuleFinder = new UsedModuleFinder {ignoreFilePatterns}


  lint: (dir) ->
    Promise.resolve [@listedModuleFinder, @usedModuleFinder]
      .map (finder) -> finder.find dir
      .then ([listedModules, usedModules]) =>
        @dependencyLinter.lint {listedModules, usedModules}


module.exports = Linter
