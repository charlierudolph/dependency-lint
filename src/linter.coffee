class Linter


  constructor: (@dir, {@allowUnused, @devFilePatterns, @devScripts, @ignoreFilePatterns}) ->


  lint: (done) =>
    async = require 'async'
    asyncHandlers = require 'async-handlers'
    async.auto {
      packageJson: @getPackageJson
      usedModules: @getUsedModules
    }, asyncHandlers.transform(@lintModules, done)


  extractListedModules: (packageJson) ->
    _ = require 'lodash'
    {
      dependencies: _.keys(packageJson.dependencies)
      devDependencies: _.keys(packageJson.devDependencies)
    }


  lintModules: ({packageJson, usedModules}) =>
    DependencyLinter = require './linter/dependency_linter'
    listedModules = @extractListedModules packageJson
    dependencyLinter = new DependencyLinter {@allowUnused, @devFilePatterns, @devScripts}
    dependencyLinter.lint {listedModules, usedModules}


  getPackageJson: (done) =>
    fsExtra = require 'fs-extra'
    path = require 'path'
    filePath = path.join @dir, 'package.json'
    fsExtra.readJson filePath, done


  getUsedModules: (done) =>
    UsedModuleFinder = require './linter/used_module_finder'
    usedModuleFinder = new UsedModuleFinder {@dir, @ignoreFilePatterns}
    usedModuleFinder.find done


module.exports = Linter
