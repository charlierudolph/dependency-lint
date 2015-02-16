colors = require 'colors/safe'
ConfigurationLoader = require './config/configuration_loader'
Linter = require './linter'
DefaultFormatter = require './formatters/default_formatter'


getConfig = (dir, done) ->
  configurationLoader = new ConfigurationLoader {dir}
  configurationLoader.load done


lint = (dir, config, done) ->
  linter = new Linter dir, config
  linter.lint done


print = (results, stream) ->
  formatter = new DefaultFormatter {stream}
  formatter.print results


exitWithError = (err) ->
  console.error colors.red(err.message)
  process.exit 1


hasError = (results) ->
  for title, modules of results
    return yes for {error} in modules when error
  no



dir = process.cwd()
getConfig dir, (err, config) ->
  if err then exitWithError err
  lint dir, config, (err, results) ->
    if err then exitWithError err
    print results, process.stdout
    process.exit 1 if hasError(results)
