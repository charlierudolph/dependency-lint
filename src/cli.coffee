extensions = require './config/supported_file_extensions'
usage = """
  Usage:
    dependency-lint [--generate-config (#{extensions.join ' | '})]

  Options:
    -h, --help           Show this screen
    --generate-config    Generate a configuration file
  """


{docopt} = require 'docopt'
options = docopt usage


generateConfig = (extension) ->
  path = require 'path'
  src = path.join __dirname, '..', 'config', "default.#{extension}"
  destFilename = "dependency-lint.#{extension}"
  dest = path.join process.cwd(), destFilename
  callback = (err) ->
    asyncHandlers = require 'async-handlers'
    asyncHandlers.exitOnError err
    console.log "Configuration file generated at \"#{destFilename}\""
  fsExtra = require 'fs-extra'
  fsExtra.copy src, dest, callback


if options['--generate-config']
  break for extension in extensions when options[extension]
  generateConfig extension
else
  require './run'
