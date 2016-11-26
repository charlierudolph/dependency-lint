_ = require 'lodash'
fs = require 'fs'
fsExtra = require 'fs-extra'
yaml = require 'js-yaml'
{coroutine} = Promise = require 'bluebird'


access = Promise.promisify fsExtra.access
readFile = Promise.promisify fs.readFile
outputFile = Promise.promisify fsExtra.outputFile


addToJsonFile = coroutine (filePath, toAdd) ->
  try
    content = yield readFile filePath, 'utf8'
  catch
    content = '{}'
  obj = JSON.parse content
  _.assign obj, toAdd
  yield outputFile filePath, JSON.stringify(obj, null, 2)


addToYmlFile = coroutine (filePath, toAdd) ->
  try
    content = yield readFile filePath, 'utf8'
  catch
    content = '{}'
  obj = yaml.safeLoad content
  _.mergeWith obj, toAdd, (objValue, srcValue) -> srcValue if _.isArray(srcValue)
  yield outputFile filePath, yaml.safeDump(obj)


module.exports = {addToJsonFile, addToYmlFile}
