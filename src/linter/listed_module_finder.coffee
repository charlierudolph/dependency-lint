_ = require 'lodash'
path = require 'path'
Promise = require 'bluebird'


class ListedModuleFinder

  find: (dir) =>
    filePath = path.join dir, 'package.json'
    Promise.try(-> require filePath).then @extractListedModules


  extractListedModules: (packageJson) ->
    result = {}
    ['dependencies', 'devDependencies'].forEach (value) ->
      result[value] = _.keys packageJson[value]
    result


module.exports = ListedModuleFinder
