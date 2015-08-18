_ = require 'lodash'
ConfigurationLoader = require './configuration_loader'
DefaultFormatter = require './formatters/default_formatter'
exitOnError = require './util/exit_on_error'
Linter = require './linter'


hasError = (results) ->
  _.any results, (modules) ->
    _.any modules, ({error}) -> error


dir = process.cwd()


new ConfigurationLoader().load dir
  .then (config) ->
    new Linter(config).lint dir
  .then (results) ->
    new DefaultFormatter({stream: process.stdout}).print results
    process.exit 1 if hasError results
  .catch exitOnError
