glob = require 'glob'
_ = require 'lodash'
path = require 'path'


class FileFinder

  constructor: ({@dir, @ignoreFiles}) ->


  find: (done) ->
    glob "#{@dir}/**/*", (err, files) =>
      if err then return done err
      done null, @filterFiles(files)


  filterFiles: (files) ->
    _.filter files, (file) =>
      return no unless @isSourceFile file
      return no if @isIgnoredFile path.relative(@dir, file)
      yes


  isIgnoredFile: (file) ->
    return yes for regex in @ignoreFiles when file.match regex
    no


  isSourceFile: (file) ->
    file.match /\.(coffee|js)$/


module.exports = FileFinder
