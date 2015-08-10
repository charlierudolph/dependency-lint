_ = require 'lodash'
fsExtra = require 'fs-extra'
Promise = require 'bluebird'

readJson = Promise.promisify fsExtra.readJson
outputJson = Promise.promisify fsExtra.outputJson


addToJsonFile = (filePath, toAdd) ->
  readJson filePath
    .catch -> {}
    .then (obj) -> _.assign obj, toAdd
    .then (obj) -> outputJson filePath, obj


module.exports = {addToJsonFile}
