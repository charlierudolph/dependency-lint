_ = require 'lodash'
{coroutine} = require 'bluebird'
ConfigurationLoader = require './configuration_loader'
DefaultFormatter = require './formatters/default_formatter'
Linter = require './linter'


hasError = (results) ->
  _.some results, (modules) ->
    _.some modules, ({error, errorIgnored}) -> error and not errorIgnored


run = coroutine ->
  dir = process.cwd()
  config = yield new ConfigurationLoader().load dir
  results = yield new Linter(config).lint dir
  new DefaultFormatter({stream: process.stdout}).print results
  process.exit 1 if hasError results


module.exports = run
