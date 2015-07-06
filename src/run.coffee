async = require 'async'
asyncHandlers = require 'async-handlers'
ConfigurationLoader = require './config/configuration_loader'
Linter = require './linter'
DefaultFormatter = require './formatters/default_formatter'


hasError = (results) ->
  for title, modules of results
    return yes for {error} in modules when error
  no


dir = process.cwd()


async.waterfall [
  (next) ->
    new ConfigurationLoader({dir}).load next
  (config, next) ->
    new Linter(dir, config).lint next
  (results, next) ->
    new DefaultFormatter({stream: process.stdout}).print results
    process.exit 1 if hasError results
], asyncHandlers.exitOnError
