class ConfigurationLoader

  constructor: ({@dir}) ->
    fsCson = require 'fs-cson'
    path = require 'path'
    @defaultConfigPath = path.join __dirname, '..', '..', 'config', 'default.json'
    fsCson.register()


  load: (done) ->
    _ = require 'lodash'
    async = require 'async'
    asyncHandlers = require 'async-handlers'
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
    fsExtra = require 'fs-extra'
    fsExtra.readJson @defaultConfigPath, done


  loadUserConfig: (done) =>
    async = require 'async'
    extensions = require './supported_file_extensions'
    fs = require 'fs'
    path = require 'path'
    filePaths = extensions.map (ext) => path.join @dir, "dependency-lint.#{ext}"
    async.waterfall [
      (next) -> async.detect filePaths, fs.exists, (result) -> next null, result
      @loadConfig
    ], done


module.exports = ConfigurationLoader
