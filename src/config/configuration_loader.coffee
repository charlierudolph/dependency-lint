_ = require 'lodash'
async = require 'async'
asyncHandlers = require 'async-handlers'
extensions = require './supported_file_extensions'
fs = require 'fs'
fsExtra = require 'fs-extra'
fsCson = require 'fs-cson'
path = require 'path'


class ConfigurationLoader

  constructor: ({@dir}) ->
    @defaultConfigPath = path.join __dirname, '..', '..', 'config', 'default.json'
    fsCson.register()


  load: (done) ->
    merge = (args) -> _.assign {}, args...
    async.parallel [
      @loadDefaultConfig
      @loadUserConfig
    ], asyncHandlers.transform(merge, done)


  loadConfig: (filePath, done) ->
    unless filePath then return done()
    try
      result = require filePath
    catch err
      if err.message.indexOf(filePath) is -1
        err.message = "#{filePath}: #{err.message}"
      done err
    done null, result


  loadDefaultConfig: (done) =>
    fsExtra.readJson @defaultConfigPath, done


  loadUserConfig: (done) =>
    filePaths = _.map extensions, (ext) => path.join @dir, "dependency-lint.#{ext}"
    async.waterfall [
      (next) -> async.detect filePaths, fs.exists, (result) -> next null, result
      @loadConfig
    ], done


module.exports = ConfigurationLoader
