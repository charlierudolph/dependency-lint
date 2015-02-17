_ = require 'lodash'
DependencyLinter = require './linter/dependency_linter'
UsedModuleFinder = require './linter/used_module_finder'
path = require 'path'


class Linter


  constructor: (@dir, {allowUnused, devFiles, devScripts, ignoreFiles}) ->
    @dependencyLinter = new DependencyLinter {allowUnused, devFiles, devScripts}
    @usedModuleFinder = new UsedModuleFinder {@dir, ignoreFiles}
    @listedModules = @getListedModules()


  lint: (done) ->
    @usedModuleFinder.find (err, usedModules) =>
      if err then return done err
      done null, @dependencyLinter.lint {@listedModules, usedModules}


  getListedModules: ->
    packageJson = require path.join(@dir, 'package.json')

    dependencies: _.keys(packageJson.dependencies)
    devDependencies: _.keys(packageJson.devDependencies)


module.exports = Linter
