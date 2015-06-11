{docopt} = require 'docopt'
fs = require 'fs-extra'
path = require 'path'
extensions = require './config/supported_file_extensions'


options = docopt """
  Usage:
    dependency-lint [--generate-config (#{extensions.join ' | '})]

  Options:
    -h, --help           Show this screen
    --generate-config    Generate a configuration file
  """


generateConfig = ->
  break for extension in extensions when options[extension]
  src = path.join __dirname, '..', 'config', "default.#{extension}"
  destFilename = "dependency-lint.#{extension}"
  dest = path.join process.cwd(), destFilename
  callback = (err) ->
    if err
      console.error err
      process.exit 1
    console.log "Configuration file generated at \"#{destFilename}\""
  fs.copy src, dest, callback


if options['--generate-config']
  generateConfig()
else
  require './run'
