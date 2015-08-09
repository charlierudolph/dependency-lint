async = require 'async'
fs = require 'fs'
path = require 'path'
RequiredModuleFinder = require './required_module_finder'
tmp = require 'tmp'


examples = [
  content: 'b = require "b"'
  description: 'coffeescript file requiring a module'
  expectedResult: [name: 'b', files: ['a.coffee']]
  filePath: 'a.coffee'
,
  content: 'b = require.resolve "b"'
  description: 'coffeescript file resolving a module'
  expectedResult: [name: 'b', files: ['a.coffee']]
  filePath: 'a.coffee'
,
  content: 'var b = require("b");'
  description: 'javascript file requiring a module'
  expectedResult: [name: 'b', files: ['a.js']]
  filePath: 'a.js'
,
  content: 'var b = require.resolve("b");'
  description: 'javascript file resolving a module'
  expectedResult: [name: 'b', files: ['a.js']]
  filePath: 'a.js'
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
            (next) => new RequiredModuleFinder(dir: @tmpDir).find (@err, @result) => next()
          ], done

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the required module', ->
          expect(@result).to.eql expectedResult
