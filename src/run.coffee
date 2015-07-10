hasError = (results) ->
  for title, modules of results
    return yes for {error} in modules when error
  no


async = require 'async'
asyncHandlers = require 'async-handlers'
dir = process.cwd()


async.waterfall [
  (next) ->
    ConfigurationLoader = require './config/configuration_loader'
    new ConfigurationLoader({dir}).load next
  (config, next) ->
    Linter = require './linter'
    new Linter(dir, config).lint next
  (results, next) ->
    DefaultFormatter = require './formatters/default_formatter'
    new DefaultFormatter({stream: process.stdout}).print results
    process.exit 1 if hasError results
], asyncHandlers.exitOnError
