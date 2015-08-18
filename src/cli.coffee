_ = require 'lodash'
{docopt} = require 'docopt'
exitOnError = require './util/exit_on_error'
extensions = require './configuration_loader/supported_file_extensions'
path = require 'path'
Promise = require 'bluebird'

copy = Promise.promisify require('fs-extra').copy


options = docopt """
  Usage:
    dependency-lint [--generate-config (#{extensions.join ' | '})]

  Options:
    -h, --help           Show this screen
    --generate-config    Generate a configuration file
  """


generateConfig = ->
  extension = _.find extensions, (ext) -> options[ext]
  src = path.join __dirname, '..', 'config', "default.#{extension}"
  destFilename = "dependency-lint.#{extension}"
  dest = path.join process.cwd(), destFilename
  copy src, dest
    .then -> console.log "Configuration file generated at \"#{destFilename}\""
    .catch exitOnError


if options['--generate-config']
  generateConfig()
else
  require './run'
