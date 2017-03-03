_ = require 'lodash'
fs = require 'fs'
getTmpDir = require '../../../spec/support/get_tmp_dir'
path = require 'path'
Promise = require 'bluebird'
RequiredModuleFinder = require './required_module_finder'


{coroutine} = Promise
writeFile = Promise.promisify fs.writeFile
symlink = Promise.promisify fs.symlink


baseBabelExample =
  filePath: 'server.js'
  filePattern: '**/*.js'
  setup: (tmpDir) ->
    filePath = path.join tmpDir, '.babelrc'
    fileContent = '{"plugins": ["transform-es2015-modules-commonjs", "syntax-dynamic-import"]}'
    writeFile filePath, fileContent
  transpilers: [{
    extension: '.js'
    fnName: 'transform'
    module: 'babel-core'
    resultKey: 'code'
  }]
baseCoffeeScriptExample =
  filePath: 'server.coffee'
  filePattern: '**/*.coffee'
  transpilers: [{extension: '.coffee', module: 'coffee-script'}]
baseJavaScriptExample =
  filePath: 'server.js'
  filePattern: '**/*.js'


examples = [
  _.assign {}, baseBabelExample,
    content: 'import myModule from "myModule'
    description: 'invalid babel'
    expectedError: yes
,
  _.assign {}, baseBabelExample,
    content: 'import myModule from "myModule"'
    description: 'babel file requiring a module'
    expectedResult: [name: 'myModule', file: 'server.js']
,
  _.assign {}, baseBabelExample,
    acornParseProps: {ecmaVersion: 6}
    content: 'import("myModule")'
    description: 'babel file with a dynamic import does not error'
    expectedResult: []
,
  _.assign {}, baseCoffeeScriptExample,
    content: 'myModule = require "myModule'
    description: 'invalid coffeescript'
    expectedError: yes
,
  _.assign {}, baseCoffeeScriptExample,
    content: 'myModule = require "myModule"'
    description: 'coffeescript file requiring a module'
    expectedResult: [name: 'myModule', file: 'server.coffee']
,
  _.assign {}, baseCoffeeScriptExample,
    content: 'myModule = require.resolve "myModule"'
    description: 'coffeescript file resolving a module'
    expectedResult: [name: 'myModule', file: 'server.coffee']
,
  _.assign {}, baseJavaScriptExample,
    content: 'var myModule = require("myModule"'
    description: 'invalid javascript'
    expectedError: yes
,
  _.assign {}, baseJavaScriptExample,
    content: 'var myModule = require("myModule");'
    description: 'javascript file requiring a module'
    expectedResult: [name: 'myModule', file: 'server.js']
,
  _.assign {}, baseJavaScriptExample,
    content: 'var myModule = require.resolve("myModule");'
    description: 'javascript file resolving a module'
    expectedResult: [name: 'myModule', file: 'server.js']
,
    _.assign {}, baseJavaScriptExample,
      content: 'var myModule = require("myModule");'
      description: 'javascript file with a coffee-script transpiler'
      expectedResult: [name: 'myModule', file: 'server.js']
      transpilers: [{extension: '.coffee', module: 'coffee-script'}]
]


describe 'RequiredModuleFinder', ->
  beforeEach coroutine ->
    @tmpDir = yield getTmpDir()
    nodeModulesPath = path.join __dirname, '..', '..', '..', 'node_modules'
    yield symlink nodeModulesPath, path.join(@tmpDir, 'node_modules')

  describe 'find', ->
    examples.forEach (example) ->
      {
        acornParseProps
        content
        description
        expectedError
        expectedResult
        filePath
        filePattern
        setup
        transpilers
      } = example

      context description, ->
        beforeEach coroutine ->
          finder = new RequiredModuleFinder {
            acornParseProps,
            files: {root: filePattern}
            transpilers
          }
          yield writeFile path.join(@tmpDir, filePath), content
          yield setup(@tmpDir) if setup
          try
            @result = yield finder.find @tmpDir
          catch error
            throw error unless expectedError
            @error = error

        if expectedError
          it 'errors with a message that includes the file path', ->
            expect(@error.message).to.include filePath
        else
          it 'returns with the required modules', ->
            expect(@result).to.eql expectedResult
