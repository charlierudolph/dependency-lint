_ = require 'lodash'
async = require 'async'
asyncHandlers = require 'async-handlers'
ConfigurationLoader = require './configuration_loader'
Linter = require './linter'
DefaultFormatter = require './formatters/default_formatter'


hasError = (results) ->
  _.any results, (modules) ->
    _.any modules, ({error}) -> error


dir = process.cwd()


async.waterfall [
  (next) ->
    new ConfigurationLoader().load dir, next
  (config, next) ->
    new Linter(config).lint dir, next
  (results, next) ->
    new DefaultFormatter({stream: process.stdout}).print results
    process.exit 1 if hasError results
], asyncHandlers.exitOnError
