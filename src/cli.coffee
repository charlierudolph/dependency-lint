{coroutine} = require 'bluebird'
{docopt} = require 'docopt'
exitWithError = require './util/exit_with_error'
packageJson = require '../package.json'


usage = '''
  Usage:
    dependency-lint [--auto-correct] [--generate-config]

  Options:
    --auto-correct       Moves mislabeled modules and removes unused modules
    -h, --help           Show this screen
    --generate-config    Generate a configuration file
    -v, --version        Show version
  '''


options = docopt usage, version: packageJson.version


do coroutine ->
  try
    file = if options['--generate-config'] then 'generate_config' else 'run'
    fn = require "./#{file}"
    fnOptions = autoCorrect: options['--auto-correct']
    yield fn fnOptions
  catch error
    exitWithError error
