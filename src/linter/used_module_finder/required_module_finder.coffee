_ = require 'lodash'
detective = require 'detective'
ModuleNameParser = require './module_name_parser'
path = require 'path'
prependToError = require '../../util/prepend_to_error'
Promise = require 'bluebird'


{coroutine} = Promise
glob = Promise.promisify require('glob')
readFile = Promise.promisify require('fs').readFile


class RequiredModuleFinder

  constructor: ({@acornParseProps, @files, @stripLoaders, @transpilers}) ->


  find: coroutine (dir) ->
    files = yield glob @files.root, {cwd: dir, ignore: @files.ignore}
    results = yield Promise.map files, (filePath) => @findInFile {dir, filePath}
    _.flatten results


  findInFile: coroutine ({dir, filePath}) ->
    content = yield readFile path.join(dir, filePath), 'utf8'
    try
      content = @compileIfNeeded {content, dir, filePath}
      moduleNames = detective content, {parse: @acornParseProps, @isRequire}
    catch err
      throw prependToError(err, filePath)
    moduleNames = @normalizeModuleNames {filePath, moduleNames}


  compileIfNeeded: ({content, dir, filePath}) ->
    ext = path.extname filePath
    transpiler = _.find @transpilers, ['extension', ext]
    if transpiler
      compiler = require transpiler.module
      fnName = transpiler.fnName or 'compile'
      result = compiler[fnName] content, {filename: path.join(dir, filePath)}
      result = result[transpiler.resultKey] if transpiler.resultKey
      result
    else
      content


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
