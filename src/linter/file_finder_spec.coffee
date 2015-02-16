FileFinder = require './file_finder'
fs = require 'fs-extra'
path = require 'path'
tmp = require 'tmp'


describe 'FileFinder', ->
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) =>
      if err then return done err
      @fileFinder = new FileFinder
        devFiles: ['^spec/', '_spec.coffee']
        dir: @tmpDir
        ignoreFiles: ['^node_modules/']
      done()

  describe 'find', ->
    context 'top level file', ->
      context 'not matching a dev regex', ->
        beforeEach (done) ->
          @filePath = path.join(@tmpDir, 'a.coffee')
          fs.outputFile @filePath, '', (err) =>
            if err then return done err
            @fileFinder.find (@err, @result) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the file under prod', ->
          expect(@result).to.eql {dev: [], prod: [@filePath]}


      context 'matching a dev regex', ->
        beforeEach (done) ->
          @filePath = path.join(@tmpDir, 'a_spec.coffee')
          fs.outputFile @filePath, '', (err) =>
            if err then return done err
            @fileFinder.find (@err, @result) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the file under dev', ->
          expect(@result).to.eql {dev: [@filePath], prod: []}


    context 'file in subfolder', ->
      context 'not matching a dev regex', ->
        beforeEach (done) ->
          @filePath = path.join(@tmpDir, 'lib/a.coffee')
          fs.outputFile @filePath, '', (err) =>
            if err then return done err
            @fileFinder.find (@err, @result) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the file under prod', ->
          expect(@result).to.eql {dev: [], prod: [@filePath]}


      context 'matching a dev regex', ->
        beforeEach (done) ->
          @filePath = path.join(@tmpDir, 'lib/a_spec.coffee')
          fs.outputFile @filePath, '', (err) =>
            if err then return done err
            @fileFinder.find (@err, @result) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the file under dev', ->
          expect(@result).to.eql {dev: [@filePath], prod: []}


      context 'matching another dev regex', ->
        beforeEach (done) ->
          @filePath = path.join(@tmpDir, 'spec/support/a.coffee')
          fs.outputFile @filePath, '', (err) =>
            if err then return done err
            @fileFinder.find (@err, @result) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the file under dev', ->
          expect(@result).to.eql {dev: [@filePath], prod: []}


    context 'file matching ignore regex', ->
      beforeEach (done) ->
        @filePath = path.join(@tmpDir, 'node_modules/a.coffee')
        fs.outputFile @filePath, '', (err) =>
          if err then return done err
          @fileFinder.find (@err, @result) => done()

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns no files', ->
        expect(@result).to.eql {dev: [], prod: []}
