async = require 'async'
fs = require 'fs'
path = require 'path'
RequiredModuleFinder = require './required_module_finder'
tmp = require 'tmp'


examples = [
  content: 'myModule = require "myModule"'
  description: 'coffeescript file requiring a module'
  expectedResult: [name: 'myModule', file: 'server.coffee']
  filePath: 'server.coffee'
,
  content: 'myModule = require.resolve "myModule"'
  description: 'coffeescript file resolving a module'
  expectedResult: [name: 'myModule', file: 'server.coffee']
  filePath: 'server.coffee'
,
  content: 'var myModule = require("myModule");'
  description: 'javascript file requiring a module'
  expectedResult: [name: 'myModule', file: 'server.js']
  filePath: 'server.js'
,
  content: 'var myModule = require.resolve("myModule");'
  description: 'javascript file resolving a module'
  expectedResult: [name: 'myModule', file: 'server.js']
  filePath: 'server.js'
]


describe 'RequiredModuleFinder', ->
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) => done err

  describe 'find', ->
    examples.forEach ({content, description, expectedResult, filePath}) ->
      context description, ->
        beforeEach (done) ->
          async.series [
            (next) => fs.writeFile path.join(@tmpDir, filePath), content, next
            (next) => new RequiredModuleFinder({}).find @tmpDir, (@err, @result) => next()
          ], done

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the required module', ->
          expect(@result).to.eql expectedResult
