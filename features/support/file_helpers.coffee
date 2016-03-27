_ = require 'lodash'
fs = require 'fs-extra'
yaml = require 'js-yaml'


addToJsonFile = (filePath, toAdd, done) ->
  fs.readFile filePath, encoding: 'utf8', (err, content) ->
    output = {}
    _.assign(output, JSON.parse(content)) unless err
    _.assign output, toAdd
    fs.outputJson filePath, output, done


addToYmlFile = (filePath, toAdd, done) ->
  fs.readFile filePath, encoding: 'utf8', (err, content) ->
    output = {}
    _.assign(output, yaml.safeLoad(content)) unless err
    customizer = (objValue, srcValue) -> if _.isArray(objValue) then return srcValue
    _.mergeWith output, toAdd, customizer
    fs.writeFile filePath, yaml.safeDump(output), done


module.exports = {addToJsonFile, addToYmlFile}
