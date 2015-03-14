_ = require 'lodash'
async = require 'async'
coffeeScript = require 'coffee-script'
detective = require 'detective'
FileFinder = require './file_finder'
fs = require 'fs'
ModuleFilterer = require './module_filterer'
path = require 'path'


class RequiredModuleFinder


  constructor: ({@dir, ignoreFiles}) ->
    @fileFinder = new FileFinder {@dir, ignoreFiles}
    @moduleFilterer = new ModuleFilterer


  find: (done) ->
    @fileFinder.find (err, files) =>
      if err then return done err
      async.map files, @findInFile, (err, results) ->
        if err then return done err
        done null, _.flatten(results)


  findInFile: (file, done) =>
    relativePath = path.relative @dir, file

    fs.readFile file, encoding: 'utf8', (err, data) =>
      if err then return done err

      if file.match /\.coffee$/
        try
          data = coffeeScript.compile data
        catch err
          err.message = "Error compiling #{relativePath}: #{err.message}"
          done err

      moduleNames = detective data, {@isRequire}
      moduleNames = @moduleFilterer.filterRequiredModules moduleNames
      done null, ({name, files: [relativePath]} for name in moduleNames)


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
