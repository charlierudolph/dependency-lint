getTmpDir = require '../../../spec/support/get_tmp_dir'
path = require 'path'
Promise = require 'bluebird'
RequiredModuleFinder = require './required_module_finder'

writeFile = Promise.promisify require('fs').writeFile


examples = [
  content: 'myModule = require "myModule"'
  description: 'coffeescript file requiring a module'
  expectedResult: [name: 'myModule', files: ['server.coffee']]
  filePath: 'server.coffee'
,
  content: 'myModule = require.resolve "myModule"'
  description: 'coffeescript file resolving a module'
  expectedResult: [name: 'myModule', files: ['server.coffee']]
  filePath: 'server.coffee'
,
  content: 'var myModule = require("myModule");'
  description: 'javascript file requiring a module'
  expectedResult: [name: 'myModule', files: ['server.js']]
  filePath: 'server.js'
,
  content: 'var myModule = require.resolve("myModule");'
  description: 'javascript file resolving a module'
  expectedResult: [name: 'myModule', files: ['server.js']]
  filePath: 'server.js'
]


describe 'RequiredModuleFinder', ->
  beforeEach ->
    @requiredModuleFinder = new RequiredModuleFinder {}
    getTmpDir().save @, 'tmpDir'

  describe 'find', ->
    examples.forEach ({content, description, expectedResult, filePath}) ->
      context description, ->
        beforeEach ->
          writeFile path.join(@tmpDir, filePath), content
            .then => @requiredModuleFinder.find(@tmpDir).save @, 'result', 'err'

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the required module', ->
          expect(@result).to.eql expectedResult
