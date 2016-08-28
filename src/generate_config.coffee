fs = require 'fs'
packageJson = require '../package.json'
path = require 'path'
Promise = require 'bluebird'


{coroutine} = Promise
readFile = Promise.promisify fs.readFile
writeFile = Promise.promisify fs.writeFile


generateConfig = coroutine ->
  src = path.join __dirname, '..', 'config', 'default.yml'
  dest = path.join process.cwd(), 'dependency-lint.yml'
  defaultConfig = yield readFile src, 'utf8'
  fileContents = """
    # See #{packageJson.homepage}/blob/v#{packageJson.version}/docs/configuration.md
    # for a detailed explanation of the options

    #{defaultConfig}
    """
  yield writeFile dest, fileContents
  console.log 'Configuration file generated at "dependency-lint.yml"'


module.exports = generateConfig
