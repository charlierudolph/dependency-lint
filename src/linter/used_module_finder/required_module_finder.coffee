_ = require 'lodash'
async = require 'async'
coffeeScript = require 'coffee-script'
detective = require 'detective'
glob = require 'glob'
fs = require 'fs'
ModuleFilterer = require './module_filterer'
path = require 'path'


class RequiredModuleFinder


  constructor: ({@dir, @ignoreFilePatterns}) ->
    @moduleFilterer = new ModuleFilterer


  find: (done) ->
    async.waterfall [
      (next) => glob '**/*.{coffee,js}', {cwd: @dir, ignore: @ignoreFilePatterns}, next
      (files, next) => async.map files, @findInFile, next
      (results, next) -> next null, _.flatten(results)
    ], done


  findInFile: (file, done) =>
    fs.readFile path.join(@dir, file), encoding: 'utf8', (err, data) =>
      if err then return done err

      if path.extname(file) is '.coffee'
        try
          data = coffeeScript.compile data
        catch err
          err.message = "Error compiling #{file}: #{err.message}"
          done err

      moduleNames = detective data, {@isRequire}
      moduleNames = @moduleFilterer.filterRequiredModules moduleNames
      done null, ({name, files: [file]} for name in moduleNames)


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
