_ = require 'lodash'
coffeeScript = require 'coffee-script'
detective = require 'detective'
ModuleFilterer = require './module_filterer'
path = require 'path'
prependToError = require '../../util/prepend_to_error'
Promise = require 'bluebird'

readFile = Promise.promisify require('fs').readFile
glob = Promise.promisify require('glob')


class RequiredModuleFinder

  constructor: ({@ignoreFilePatterns}) ->


  find: (dir) ->
    glob '**/*.{coffee,js}', cwd: dir, ignore: @ignoreFilePatterns
      .map (filePath) => @findInFile {dir, filePath}
      .then _.flatten


  findInFile: ({dir, filePath}) ->
    readFile path.join(dir, filePath), 'utf8'
      .then (content) => @compile {content, filePath}
      .then (content) => @findInContent {content, filePath}


  compile: ({content, filePath}) ->
    if path.extname(filePath) is '.coffee'
      coffeeScript.compile content, filename: filePath
    else
      content


  findInContent: ({content, filePath}) ->
    moduleNames = detective content, {@isRequire}
    moduleNames = ModuleFilterer.filterRequiredModules moduleNames
    {name, files: [filePath]} for name in moduleNames


  isRequire: ({type, callee}) ->
    type is 'CallExpression' and
      ((callee.type is 'Identifier' and
        callee.name is 'require') or
       (callee.type is 'MemberExpression' and
        callee.object.type is 'Identifier' and
        callee.object.name is 'require' and
        callee.property.type is 'Identifier' and
        callee.property.name is 'resolve'))


module.exports = RequiredModuleFinder
