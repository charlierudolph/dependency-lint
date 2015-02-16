async = require 'async'
coffeeScript = require 'coffee-script'
detective = require 'detective'
FileFinder = require './file_finder'
fs = require 'fs'
_ = require 'lodash'


class RequiredModuleFinder

  constructor: ({devFiles, dir, ignoreFiles}) ->
    @fileFinder = new FileFinder {devFiles, dir, ignoreFiles}


  find: (done) ->
    @fileFinder.find (err, files) =>
      if err then return done err
      async.parallel [
        (taskDone) => async.map files.prod, @findInFile, taskDone
        (taskDone) => async.map files.dev, @findInFile, taskDone
      ], (err, results) ->
        if err then return done err
        [prod, dev] = (_.flatten(result) for result in results)
        done null, {prod, dev}



  findInFile: (file, done) =>
    fs.readFile file, encoding: 'utf8', (err, data) =>
      if err then return done err

      if file.match /\.coffee$/
        try
          data = coffeeScript.compile data
        catch err
          done err, null

      done null, detective(data, {@isRequire})


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
