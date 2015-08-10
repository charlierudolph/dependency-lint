_ = require 'lodash'
async = require 'async'
coffeeScript = require 'coffee-script'
detective = require 'detective'
glob = require 'glob'
fs = require 'fs'
ModuleFilterer = require './module_filterer'
path = require 'path'


class RequiredModuleFinder

  constructor: ({@ignoreFilePatterns}) ->


  find: (dir, done) ->
    async.waterfall [
      (next) => glob '**/*.{coffee,js}', {cwd: dir, ignore: @ignoreFilePatterns}, next
      (files, next) =>
        iterator = (filePath, cb) => @findInFile {dir, filePath}, cb
        async.concat files, iterator, next
    ], done


  findInFile: ({dir, filePath}, done) ->
    async.waterfall [
      (next) ->
        fs.readFile path.join(dir, filePath), encoding: 'utf8', next
      (content, next) =>
        @compile {content, filePath}, next
      (content, next) =>
        next null, @findInContent({content, filePath})
    ], done


  compile: ({content, filePath}, done) ->
    if path.extname(filePath) is '.coffee'
      @compileCoffeescript {content, filePath}, done
    else
      done null, content


  compileCoffeescript: ({content, filePath}, done) ->
    try
      result = coffeeScript.compile content, filename: filePath
    catch err
      return done err
    done null, result


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
