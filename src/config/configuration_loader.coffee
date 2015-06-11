_ = require 'lodash'
async = require 'async'
extensions = require './supported_file_extensions'
fs = require 'fs'
fsCson = require 'fs-cson'
path = require 'path'


class ConfigurationLoader

  constructor: ({@dir}) ->
    @defaultConfig = @loadDetaultConfig()
    fsCson.register()


  load: (done) ->
    @loadUserConfig (err, userConfig) =>
      if err then return done err
      config = _.assign {}, @defaultConfig, userConfig
      done null, config


  loadDetaultConfig: ->
    require path.join(__dirname, '..', '..', 'config', 'default.json')


  loadUserConfig: (done) ->
    filePaths = _.map extensions, (ext) => path.join @dir, "dependency-lint.#{ext}"
    callback = (filePath) ->
      config = if filePath then require filePath
      done null, config
    async.detect filePaths, fs.exists, callback


module.exports = ConfigurationLoader
