glob = require 'glob'
path = require 'path'


class FileFinder

  constructor: ({@devFiles, @dir, @ignoreFiles}) ->


  find: (done) ->
    glob "#{@dir}/**/*", (err, files) =>
      if err then return done err
      done null, @parseFiles(files)


  parseFiles: (files) ->
    result = prod: [], dev: []
    for file in files
      relativePath = path.relative @dir, file
      continue unless @isSourceFile(relativePath) and not @isIgnoredFile(relativePath)
      key = if @isDevFile(relativePath) then 'dev' else 'prod'
      result[key].push file
    result


  isDevFile: (file) ->
    return yes for regex in @devFiles when file.match regex
    no


  isIgnoredFile: (file) ->
    return yes for regex in @ignoreFiles when file.match regex
    no


  isSourceFile: (file) ->
    file.match /\.(coffee|js)$/


module.exports = FileFinder
