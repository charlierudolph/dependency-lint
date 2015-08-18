_ = require 'lodash'
fsExtra = require 'fs-extra'
Promise = require 'bluebird'

access = Promise.promisify require('fs').access
outputJson = Promise.promisify fsExtra.outputJson
readJson = Promise.promisify fsExtra.readJson


addToJsonFile = (filePath, toAdd) ->
  access filePath
    .then (-> readJson filePath), (-> {})
    .then (obj) -> _.assign obj, toAdd
    .then (obj) -> outputJson filePath, obj


module.exports = {addToJsonFile}
