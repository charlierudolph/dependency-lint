extensions = require './config/supported_file_extensions'
{docopt} = require 'docopt'
options = docopt """
  Usage:
    dependency-lint [--generate-config (#{extensions.join ' | '})]

  Options:
    -h, --help           Show this screen
    --generate-config    Generate a configuration file
  """


generateConfig = (extension) ->
  fsExtra = require 'fs-extra'
  path = require 'path'
  break for extension in extensions when options[extension]
  src = path.join __dirname, '..', 'config', "default.#{extension}"
  destFilename = "dependency-lint.#{extension}"
  dest = path.join process.cwd(), destFilename
  callback = (err) ->
    asyncHandlers = require 'async-handlers'
    asyncHandlers.exitOnError err
    console.log "Configuration file generated at \"#{destFilename}\""
  fsExtra.copy src, dest, callback


if options['--generate-config']
  generateConfig()
else
  require './run'
