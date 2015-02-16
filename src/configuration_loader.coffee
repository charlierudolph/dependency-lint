_ = require 'lodash'
fs = require 'fs'
path = require 'path'


class ConfigurationLoader

  constructor: ({@dir}) ->
    @defaultConfig = @loadDetaultConfig()
    @userConfigPath = path.join(@dir, 'dependency-lint.json')


  load: (done) ->
    @loadUserConfig (err, userConfig) =>
      if err then return done err
      config = _.assign {@dir}, @defaultConfig, userConfig
      done null, config


  loadDetaultConfig: ->
    require path.join(__dirname, '..', 'config', 'default.json')


  loadUserConfig: (done) ->
    fs.exists @userConfigPath, (exists) =>
      config = if exists then require(@userConfigPath) else {}
      done null, config


module.exports = ConfigurationLoader
