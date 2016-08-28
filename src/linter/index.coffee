_ = require 'lodash'
DependencyLinter = require './dependency_linter'
fsExtra = require 'fs-extra'
InstalledModuleValidater = require './installed_module_validator'
path = require 'path'
Promise = require 'bluebird'
UsedModuleFinder = require './used_module_finder'


{coroutine} = Promise
readJson = Promise.promisify fsExtra.readJson


class Linter

  constructor: (config) ->
    @dependencyLinter = new DependencyLinter config
    @installedModuleValidater = new InstalledModuleValidater
    @usedModuleFinder = new UsedModuleFinder config


  lint: coroutine (dir) ->
    packageJson = yield readJson path.join(dir, 'package.json')
    yield @installedModuleValidater.validate {dir, packageJson}
    usedModules = yield @usedModuleFinder.find {dir, packageJson}
    listedModules = @getListedModules packageJson
    @dependencyLinter.lint {listedModules, usedModules}


  getListedModules: (packageJson) ->
    result = {}
    ['dependencies', 'devDependencies'].forEach (value) ->
      result[value] = _.keys packageJson[value]
    result


module.exports = Linter
