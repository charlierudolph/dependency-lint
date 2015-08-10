_ = require 'lodash'
extensions = require './supported_file_extensions'
fs = require 'fs'
path = require 'path'
prependToError = require '../util/prepend_to_error'
Promise = require 'bluebird'
yaml = require 'js-yaml'

require 'coffee-script/register'
require 'fs-cson/register'

access = Promise.promisify fs.access
readFile = Promise.promisify fs.readFile

defaultConfigPath = path.join __dirname, '..', '..', 'config', 'default.json'
defaultConfig = require defaultConfigPath


class ConfigurationLoader


  load: (dir) ->
    @loadUserConfig dir
      .then (userConfig) -> _.assign {}, defaultConfig, userConfig


  findUserConfig: (dir) ->
    promises = extensions.map (ext) ->
      filePath = path.join dir, "dependency-lint.#{ext}"
      access(filePath).then -> filePath
    Promise.any(promises)
      .catch -> # user config is not required


  loadConfig: (filePath) ->
    return unless filePath
    handler = prependToError filePath
    switch path.extname filePath
      when '.coffee', '.cson', '.js', '.json'
        Promise.try(-> require filePath)
          .catch handler
      when '.yml', '.yaml'
        readFile filePath, 'utf8'
          .then yaml.safeLoad
          .catch handler


  loadUserConfig: (dir) =>
    @findUserConfig(dir).then @loadConfig


module.exports = ConfigurationLoader
