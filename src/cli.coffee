{docopt} = require 'docopt'
fs = require 'fs-extra'
path = require 'path'

usage = '''
  Usage:
    dependency-lint [options]

  Options:
    -h, --help           Show this screen
    --generate-config    Generate a configuration file
  '''

options = docopt usage

if options['--generate-config']
  fs.copy(
    path.join(__dirname, '..', 'config', 'default.json')
    path.join(process.cwd(), 'dependency-lint.json')
    (err) ->
      if err
        console.error err
        process.exit 1

      console.log 'Configuration file generated at "dependency-lint.json"'
  )
else
  require './run'
