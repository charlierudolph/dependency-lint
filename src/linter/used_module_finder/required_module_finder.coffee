_ = require 'lodash'
async = require 'async'
detective = require 'detective'
glob = require 'glob'
fs = require 'fs'
ModuleNameParser = require './module_name_parser'
path = require 'path'


class RequiredModuleFinder

  constructor: ({@filePattern, @ignoreFilePatterns, @stripLoaders, @transpilers}) ->


  find: (dir, done) ->
    async.waterfall [
      (next) => glob @filePattern, {cwd: dir, ignore: @ignoreFilePatterns}, next
      (files, next) =>
        iterator = (filePath, cb) => @findInFile {dir, filePath}, cb
        async.concat files, iterator, next
    ], done


  findInFile: ({dir, filePath}, done) ->
    async.waterfall [
      (next) ->
        fs.readFile path.join(dir, filePath), encoding: 'utf8', next
      (content, next) =>
        @compileIfNeeded {content, filePath}, next
      (content, next) =>
        @findInContent {content, filePath}, next
      (moduleNames, next) =>
        next null, @normalizeModuleNames {filePath, moduleNames}
    ], done


  compileIfNeeded: ({content, filePath}, done) ->
    ext = path.extname filePath
    transpiler = _.find @transpilers, 'extension', ext
    if transpiler
      compiler = require transpiler.module
      @compile {compiler, content, filePath}, done
    else
      done null, content


  compile: ({compiler, content, filePath}, done) ->
    try
      result = compiler.compile content, {filename: filePath}
    catch err
      return done err
    done null, result


  findInContent: ({content, filePath}, done) ->
    try
      result = detective content, {@isRequire}
    catch err
      err.message = "#{filePath}: #{err.message}"
      return done err
    done null, result


  isRequire: ({type, callee}) ->
    type is 'CallExpression' and
      ((callee.type is 'Identifier' and
        callee.name is 'require') or
       (callee.type is 'MemberExpression' and
        callee.object.type is 'Identifier' and
        callee.object.name is 'require' and
        callee.property.type is 'Identifier' and
        callee.property.name is 'resolve'))


  normalizeModuleNames: ({filePath, moduleNames}) ->
    _.chain moduleNames
      .map if @stripLoaders then ModuleNameParser.stripLoaders
      .reject ModuleNameParser.isBuiltIn
      .reject ModuleNameParser.isRelative
      .map ModuleNameParser.stripSubpath
      .map (name) -> {name, file: filePath}
      .value()


module.exports = RequiredModuleFinder
