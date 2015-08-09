_ = require 'lodash'
asyncHandlers = require 'async-handlers'
fsExtra = require 'fs-extra'
path = require 'path'


class ListedModuleFinder

  constructor: ({@dir}) ->


  find: (done) =>
    filePath = path.join @dir, 'package.json'
    callback = asyncHandlers.transform @extractListedModules, done
    fsExtra.readJson filePath, callback


  extractListedModules: (packageJson) ->
    result = {}
    ['dependencies', 'devDependencies'].forEach (value) ->
      result[value] = _.keys packageJson[value]
    result


module.exports = ListedModuleFinder
