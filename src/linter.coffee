class Linter


  constructor: (@dir, {@allowUnused, @devFilePatterns, @devScripts, @ignoreFilePatterns}) ->


  lint: (done) ->
    asyncHandlers = require 'async-handlers'
    handler = asyncHandlers.transform @lintModules, done
    async = require 'async'
    async.parallel {@listedModules, @usedModules}, handler


  # Private
  extractListedModules: (packageJson) ->
    {
      dependencies: Object.keys(packageJson.dependencies or {})
      devDependencies: Object.keys(packageJson.devDependencies or {})
    }


  # Private
  lintModules: ({listedModules, usedModules}) =>
    DependencyLinter = require './linter/dependency_linter'
    dependencyLinter = new DependencyLinter {@allowUnused, @devFilePatterns, @devScripts}
    dependencyLinter.lint {listedModules, usedModules}


  # Private
  listedModules: (done) =>
    path = require 'path'
    filePath = path.join @dir, 'package.json'
    asyncHandlers = require 'async-handlers'
    handler = asyncHandlers.transform @extractListedModules, done
    fsExtra = require 'fs-extra'
    fsExtra.readJson filePath, handler


  # Private
  usedModules: (done) =>
    UsedModuleFinder = require './linter/used_module_finder'
    usedModuleFinder = new UsedModuleFinder {@dir, @ignoreFilePatterns}
    usedModuleFinder.find done


module.exports = Linter
