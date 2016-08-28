fs = require 'fs'
getTmpDir = require '../../../spec/support/get_tmp_dir'
path = require 'path'
Promise = require 'bluebird'
RequiredModuleFinder = require './required_module_finder'


{coroutine} = Promise
writeFile = Promise.promisify fs.writeFile


examples = [
  content: 'myModule = require "myModule'
  description: 'invalid coffeescript'
  expectedError: yes
  filePath: 'server.coffee'
  filePattern: '**/*.coffee'
  transpilers: [{extension: '.coffee', module: 'coffee-script'}]
,
  content: 'myModule = require "myModule"'
  description: 'coffeescript file requiring a module'
  expectedResult: [name: 'myModule', file: 'server.coffee']
  filePath: 'server.coffee'
  filePattern: '**/*.coffee'
  transpilers: [{extension: '.coffee', module: 'coffee-script'}]
,
  content: 'myModule = require.resolve "myModule"'
  description: 'coffeescript file resolving a module'
  expectedResult: [name: 'myModule', file: 'server.coffee']
  filePath: 'server.coffee'
  filePattern: '**/*.coffee'
  transpilers: [{extension: '.coffee', module: 'coffee-script'}]
,
  content: 'var myModule = require("myModule"'
  description: 'invalid javascript'
  expectedError: yes
  filePath: 'server.js'
  filePattern: '**/*.js'
,
  content: 'var myModule = require("myModule");'
  description: 'javascript file requiring a module'
  expectedResult: [name: 'myModule', file: 'server.js']
  filePath: 'server.js'
  filePattern: '**/*.js'
,
  content: 'var myModule = require.resolve("myModule");'
  description: 'javascript file resolving a module'
  expectedResult: [name: 'myModule', file: 'server.js']
  filePath: 'server.js'
  filePattern: '**/*.js'
]


describe 'RequiredModuleFinder', ->
  beforeEach coroutine ->
    @tmpDir = yield getTmpDir()

  describe 'find', ->
    examples.forEach (example) ->
      {
        content
        description
        expectedError
        expectedResult
        filePath
        filePattern
        transpilers
      } = example

      context description, ->
        beforeEach coroutine ->
          finder = new RequiredModuleFinder {files: {root: filePattern}, transpilers}
          yield writeFile path.join(@tmpDir, filePath), content
          try
            @result = yield finder.find @tmpDir
          catch error
            @error = error

        if expectedError
          it 'errors with a message that includes the file path', ->
            expect(@error.message).to.include filePath
        else
          it 'returns with the required modules', ->
            expect(@result).to.eql expectedResult
