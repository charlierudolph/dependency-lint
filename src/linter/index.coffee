_ = require 'lodash'
DependencyLinter = require './dependency_linter'
fsExtra = require 'fs-extra'
InstalledModuleValidater = require './installed_module_validator'
path = require 'path'
UsedModuleFinder = require './used_module_finder'


class Linter

  constructor: (config) ->
    @dependencyLinter = new DependencyLinter config
    @installedModuleValidater = new InstalledModuleValidater
    @usedModuleFinder = new UsedModuleFinder config


  lint: (dir, done) ->
    @readPackageJson dir, (err, packageJson) =>
      if err then return done err
      @installedModuleValidater.validate {dir, packageJson}, (err) =>
        if err then return done err
        @usedModuleFinder.find {dir, packageJson}, (err, usedModules) =>
          if err then return done err
          listedModules = @getListedModules packageJson
          result = @dependencyLinter.lint {listedModules, usedModules}
          done null, result


  readPackageJson: (dir, done) ->
    filePath = path.join dir, 'package.json'
    fsExtra.readJson filePath, done


  getListedModules: (packageJson) ->
    result = {}
    ['dependencies', 'devDependencies'].forEach (value) ->
      result[value] = _.keys packageJson[value]
    result


module.exports = Linter
