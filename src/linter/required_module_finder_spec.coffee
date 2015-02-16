fs = require 'fs-extra'
path = require 'path'
RequiredModuleFinder = require './required_module_finder'
tmp = require 'tmp'


describe 'RequiredModuleFinder', ->
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) =>
      if err then return done err
      @requiredModuleFinder = new RequiredModuleFinder {dir: @tmpDir}
      @fileFinderStub = sinon.stub @requiredModuleFinder.fileFinder, 'find'
      done()

  describe 'find', ->
    context 'coffeescript file requiring a module', ->
      beforeEach (done) ->
        @filePath = path.join(@tmpDir, 'a.coffee')
        fs.outputFile @filePath, 'b = require "b"', done

      context 'that is a production file', ->
        beforeEach (done) ->
          @fileFinderStub.callsArgWith 0, null, {dev: [], prod: [@filePath]}
          @requiredModuleFinder.find (@err, @result) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the required module under prod', ->
          expect(@result).to.eql {dev: [], prod: ['b']}

      context 'that is a development file', ->
        beforeEach (done) ->
          @fileFinderStub.callsArgWith 0, null, {dev: [@filePath], prod: []}
          @requiredModuleFinder.find (@err, @result) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the required module under dev', ->
          expect(@result).to.eql {dev: ['b'], prod: []}


    context 'coffeescript file resolving a module', ->
      beforeEach (done) ->
        @filePath = path.join(@tmpDir, 'a.coffee')
        fs.outputFile @filePath, 'b = require.resolve "b"', done

      context 'that is a production file', ->
        beforeEach (done) ->
          @fileFinderStub.callsArgWith 0, null, {dev: [], prod: [@filePath]}
          @requiredModuleFinder.find (@err, @result) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the required module under prod', ->
          expect(@result).to.eql {dev: [], prod: ['b']}

      context 'that is a development file', ->
        beforeEach (done) ->
          @fileFinderStub.callsArgWith 0, null, {dev: [@filePath], prod: []}
          @requiredModuleFinder.find (@err, @result) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the required module under dev', ->
          expect(@result).to.eql {dev: ['b'], prod: []}


    context 'javascript file requiring a module', ->
      beforeEach (done) ->
        @filePath = path.join(@tmpDir, 'a.js')
        fs.outputFile @filePath, 'var b = require("b");', done

      context 'that is a production file', ->
        beforeEach (done) ->
          @fileFinderStub.callsArgWith 0, null, {dev: [], prod: [@filePath]}
          @requiredModuleFinder.find (@err, @result) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the required module under prod', ->
          expect(@result).to.eql {dev: [], prod: ['b']}

      context 'returned as devFile', ->
        beforeEach (done) ->
          @fileFinderStub.callsArgWith 0, null, {dev: [@filePath], prod: []}
          @requiredModuleFinder.find (@err, @result) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the required module under dev', ->
          expect(@result).to.eql {dev: ['b'], prod: []}

    context 'error while finding files', ->
      beforeEach (done) ->
        @fileFinderStub.callsArgWith 0, 'some error'
        @requiredModuleFinder.find (@err, @result) => done()

      it 'returns an error', ->
        expect(@err).to.eql 'some error'

      it 'does not return dependencies or devDependencies', ->
        expect(@result).to.not.exist
