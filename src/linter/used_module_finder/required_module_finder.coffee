_ = require 'lodash'
async = require 'async'
coffeeScript = require 'coffee-script'
detective = require 'detective'
FileFinder = require './file_finder'
fs = require 'fs'
path = require 'path'


class RequiredModuleFinder

  BUILT_IN_MODULES: [
    'assert', 'buffer', 'child_process', 'cluster', 'crypto', 'dgram', 'dns', 'domain', 'events',
    'fs', 'http', 'https', 'net', 'os', 'path', 'punycode', 'querystring', 'readline', 'reply',
    'stream', 'string_decoder', 'tls', 'tty', 'url', 'util', 'vm', 'zlib'
  ]


  constructor: ({@dir, ignoreFiles}) ->
    @fileFinder = new FileFinder {@dir, ignoreFiles}


  find: (done) ->
    @fileFinder.find (err, files) =>
      if err then return done err
      async.map files, @findInFile, (err, results) ->
        if err then return done err
        done null, _.flatten(results)


  findInFile: (file, done) =>
    fs.readFile file, encoding: 'utf8', (err, data) =>
      if err then return done err

      if file.match /\.coffee$/
        try
          data = coffeeScript.compile data
        catch err
          err.message = "Error compiling #{path.relative @dir, file}: #{err.message}"
          done err

      moduleNames = _.chain(detective data, {@isRequire})
        .filter (name) => name[0] isnt '.' and name not in @BUILT_IN_MODULES
        .map (name) -> name.replace /\/.*$/, ''
        .value()

      relativePath = path.relative @dir, file

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
