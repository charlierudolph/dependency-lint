async = require 'async'
fs = require 'fs'
path = require 'path'
RequiredModuleFinder = require './required_module_finder'
tmp = require 'tmp'


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
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) => done err

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
        beforeEach (done) ->
          async.series [
            (next) => fs.writeFile path.join(@tmpDir, filePath), content, next
            (next) =>
              finder = new RequiredModuleFinder {filePattern, transpilers}
              finder.find @tmpDir, (@err, @result) => next()
          ], done

        if expectedError
          it 'returns an error', ->
            expect(@err).to.exist
            expect(@err.stack).to.include filePath

        else
          it 'does not return an error', ->
            expect(@err).to.not.exist

          it 'returns the required module', ->
            expect(@result).to.eql expectedResult
