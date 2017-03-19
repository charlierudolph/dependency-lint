_ = require 'lodash'
AutoCorrector = require './auto_corrector'
ConfigurationLoader = require './configuration_loader'
fsExtra = require 'fs-extra'
JsonFormatter = require './formatters/json_formatter'
Linter = require './linter'
path = require 'path'
Promise = require 'bluebird'
SummaryFormatter = require './formatters/summary_formatter'


{coroutine} = Promise
readJson = Promise.promisify fsExtra.readJson
writeJson = Promise.promisify fsExtra.writeJson


getFormatter = (format) ->
  options = stream: process.stdout
  switch format
    when 'minimal' then new SummaryFormatter _.assign {minimal: true}, options
    when 'summary' then new SummaryFormatter options
    when 'json' then new JsonFormatter options


hasError = (results) ->
  _.some results, (modules) ->
    _.some modules, ({error, errorFixed, errorIgnored}) ->
      error and not (errorFixed or errorIgnored)


run = coroutine ({autoCorrect, format}) ->
  dir = process.cwd()
  packageJsonPath = path.join(dir, 'package.json')
  packageJson = yield readJson packageJsonPath
  config = yield new ConfigurationLoader().load dir
  results = yield new Linter(config).lint {dir, packageJson}
  if autoCorrect
    {fixes, updatedPackageJson} = new AutoCorrector().correct {packageJson, results}
    yield writeJson packageJsonPath, updatedPackageJson, spaces: 2
  getFormatter(format).print {fixes, results}
  process.exit 1 if hasError results


module.exports = run
