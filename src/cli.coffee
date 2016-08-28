{coroutine} = require 'bluebird'
{docopt} = require 'docopt'
exitWithError = require './util/exit_with_error'
packageJson = require '../package.json'


usage = '''
  Usage:
    dependency-lint [--generate-config]

  Options:
    -h, --help           Show this screen
    --generate-config    Generate a configuration file
    -v, --version        Show version
  '''


options = docopt usage, version: packageJson.version


file = if options['--generate-config'] then 'generate_config' else 'run'
fn = require "./#{file}"
do coroutine ->
  try
    yield fn()
  catch error
    exitWithError error
