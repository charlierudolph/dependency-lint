_ = require 'lodash'
async = require 'async'
asyncHandlers = require 'async-handlers'
fsExtra = require 'fs-extra'
DependencyLinter = require './linter/dependency_linter'
UsedModuleFinder = require './linter/used_module_finder'
path = require 'path'


class Linter


  constructor: (@dir, {allowUnused, devFilePatterns, devScripts, ignoreFilePatterns}) ->
    @dependencyLinter = new DependencyLinter {allowUnused, devFilePatterns, devScripts}
    @usedModuleFinder = new UsedModuleFinder {@dir, ignoreFilePatterns}


  lint: (done) ->
    async.parallel {
      listedModules: @getListedModules
      usedModules: @usedModuleFinder.find
    }, asyncHandlers.transform(@dependencyLinter.lint, done)


  extractListedModules: (packageJson) ->
    {
      dependencies: _.keys(packageJson.dependencies)
      devDependencies: _.keys(packageJson.devDependencies)
    }


  getListedModules: (done) =>
    filePath = path.join @dir, 'package.json'
    callback = asyncHandlers.transform @extractListedModules, done
    fsExtra.readJson filePath, callback


module.exports = Linter
