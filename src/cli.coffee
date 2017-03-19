{coroutine} = require 'bluebird'
{docopt} = require 'docopt'
exitWithError = require './util/exit_with_error'
packageJson = require '../package.json'


usage = '''
  Usage:
    dependency-lint [--auto-correct] [--generate-config] [--format <format>]

  Options:
    --auto-correct       Moves mislabeled modules and removes unused modules
    --format <format>    Select the formatter: json, minimal (default), summary
    -h, --help           Show this screen
    --generate-config    Generate a configuration file
    -v, --version        Show version
  '''


options = docopt usage, version: packageJson.version


do coroutine ->
  try
    file = if options['--generate-config'] then 'generate_config' else 'run'
    fn = require "./#{file}"
    format = options['--format'] or 'minimal'
    if format not in ['json', 'minimal', 'summary']
      throw new Error "Invalid format: '#{format}'. Valid formats: json, minimal, or summary"
    yield fn {autoCorrect: options['--auto-correct'], format}
  catch error
    exitWithError error
