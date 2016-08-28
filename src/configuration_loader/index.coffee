_ = require 'lodash'
fs = require 'fs'
path = require 'path'
Promise = require 'bluebird'
yaml = require 'js-yaml'


{coroutine} = Promise
access = Promise.promisify fs.access
readFile = Promise.promisify fs.readFile


class ConfigurationLoader

  defaultConfigPath: path.join __dirname, '..', '..', 'config', 'default.yml'


  load: coroutine (dir) ->
    [defaultConfig, userConfig] = yield Promise.all [@loadDefaultConfig(), @loadUserConfig dir]
    customizer = (objValue, srcValue) -> srcValue if _.isArray(srcValue)
    _.mergeWith {}, defaultConfig, userConfig, customizer


  loadConfig: coroutine (filePath) ->
    content = yield readFile filePath, 'utf8'
    yaml.safeLoad content, filename: filePath


  loadDefaultConfig: ->
    @loadConfig @defaultConfigPath


  loadUserConfig: coroutine (dir) ->
    userConfigPath = path.join dir, 'dependency-lint.yml'
    try
      yield access userConfigPath
    catch
      return {}
    yield @loadConfig userConfigPath


module.exports = ConfigurationLoader
