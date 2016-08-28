_ = require 'lodash'
AutoCorrector = require './auto_corrector'
ConfigurationLoader = require './configuration_loader'
DefaultFormatter = require './formatters/default_formatter'
fsExtra = require 'fs-extra'
Linter = require './linter'
path = require 'path'
Promise = require 'bluebird'


{coroutine} = Promise
readJson = Promise.promisify fsExtra.readJson
writeJson = Promise.promisify fsExtra.writeJson


hasError = (results) ->
  _.some results, (modules) ->
    _.some modules, ({error, errorFixed, errorIgnored}) ->
      error and not (errorFixed or errorIgnored)


run = coroutine ({autoCorrect}) ->
  dir = process.cwd()
  packageJsonPath = path.join(dir, 'package.json')
  packageJson = yield readJson packageJsonPath
  config = yield new ConfigurationLoader().load dir
  results = yield new Linter(config).lint {dir, packageJson}
  if autoCorrect
    {fixes, updatedPackageJson} = new AutoCorrector().correct {packageJson, results}
    yield writeJson packageJsonPath, updatedPackageJson
  new DefaultFormatter({stream: process.stdout}).print {fixes, results}
  process.exit 1 if hasError results


module.exports = run
