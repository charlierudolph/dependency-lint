_ = require 'lodash'
async = require 'async'
asyncHandlers = require 'async-handlers'
fs = require 'fs'
path = require 'path'
yaml = require 'js-yaml'


class ConfigurationLoader

  defaultConfigPath: path.join __dirname, '..', '..', 'config', 'default.yml'


  load: (dir, done) ->
    customizer = (objValue, srcValue) -> if _.isArray(objValue) then return srcValue
    merge = (args) -> _.mergeWith args..., customizer
    async.parallel [
      @loadDefaultConfig
      (next) => @loadUserConfig dir, next
    ], asyncHandlers.transform(merge, done)


  loadConfig: (filePath, done) =>
    return done() unless filePath
    handler = asyncHandlers.prependToError filePath, done
    async.waterfall [
      (next) -> fs.readFile filePath, 'utf8', next
      (content, next) => @toAsync (-> yaml.safeLoad content), next
    ], handler


  loadDefaultConfig: (done) =>
    @loadConfig @defaultConfigPath, done


  loadUserConfig: (dir, done) =>
    userConfigPath = path.join dir, 'dependency-lint.yml'
    fs.exists userConfigPath, (exists) =>
      unless exists then return done null, {}
      @loadConfig userConfigPath, done


  toAsync: (fn, done) ->
    try
      result = fn()
    catch err
      done err
    done null, result


module.exports = ConfigurationLoader
