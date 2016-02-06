asyncHandlers = require 'async-handlers'
{docopt} = require 'docopt'
fs = require 'fs-extra'
path = require 'path'


options = docopt '''
  Usage:
    dependency-lint [--generate-config]

  Options:
    -h, --help           Show this screen
    --generate-config    Generate a configuration file
  '''


generateConfig = ->
  src = path.join __dirname, '..', 'config', 'default.yml'
  dest = path.join process.cwd(), 'dependency-lint.yml'
  callback = (err) ->
    asyncHandlers.exitOnError err
    console.log 'Configuration file generated at "dependency-lint.yml"'
  fs.copy src, dest, callback


if options['--generate-config']
  generateConfig()
else
  require './run'
