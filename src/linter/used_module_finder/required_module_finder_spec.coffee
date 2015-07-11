async = require 'async'
fs = require 'fs'
path = require 'path'
RequiredModuleFinder = require './required_module_finder'
tmp = require 'tmp'


describe 'RequiredModuleFinder', ->
  before ->
    @writeContentAndFineModules = ({filePath, content}, done) =>
      async.series [
        (next) -> fs.writeFile filePath, content, next
        (next) => new RequiredModuleFinder(dir: @tmpDir).find (@err, @result) => next()
      ], done


  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) => done err


  describe 'find', ->
    context 'coffeescript file requiring a module', ->
      beforeEach (done) ->
        filePath = path.join @tmpDir, 'a.coffee'
        content = 'b = require "b"'
        @writeContentAndFineModules {filePath, content}, done

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the required module', ->
        expect(@result).to.eql [name: 'b', files: ['a.coffee']]


    context 'coffeescript file resolving a module', ->
      beforeEach (done) ->
        filePath = path.join @tmpDir, 'a.coffee'
        content = 'b = require.resolve "b"'
        @writeContentAndFineModules {filePath, content}, done

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the required module', ->
        expect(@result).to.eql [name: 'b', files: ['a.coffee']]


    context 'javascript file requiring a module', ->
      beforeEach (done) ->
        filePath = path.join @tmpDir, 'a.js'
        content = 'var b = require("b");'
        @writeContentAndFineModules {filePath, content}, done

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the required module', ->
        expect(@result).to.eql [name: 'b', files: ['a.js']]
