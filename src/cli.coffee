async = require 'async'
asyncHandlers = require 'async-handlers'
{docopt} = require 'docopt'
fs = require 'fs-extra'
path = require 'path'
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


generateConfig = ->
  src = path.join __dirname, '..', 'config', 'default.yml'
  dest = path.join process.cwd(), 'dependency-lint.yml'
  callback = (err) ->
    asyncHandlers.exitOnError err
    console.log 'Configuration file generated at "dependency-lint.yml"'
  async.waterfall [
    (next) -> fs.readFile src, 'utf8', next
    (contents, next) ->
      comment = """
        # See #{packageJson.homepage}/blob/v#{packageJson.version}/docs/configuration.md
        # for a detailed explanation of the options
        """
      fs.writeFile dest, comment + '\n\n' + contents, next
  ], callback


if options['--generate-config']
  generateConfig()
else
  require './run'
