_ = require 'lodash'
fs = require 'fs-extra'


addToJsonFile = (filePath, toAdd, done) ->
  fs.readFile filePath, encoding: 'utf8', (err, data) ->
    output = {}
    _.assign(output, JSON.parse(data)) unless err
    _.assign output, toAdd
    fs.outputJson filePath, output, done


module.exports = {addToJsonFile}
