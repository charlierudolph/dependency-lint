FileFinder = require './file_finder'
fs = require 'fs-extra'
path = require 'path'
tmp = require 'tmp'


describe 'FileFinder', ->
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) =>
      if err then return done err
      @fileFinder = new FileFinder
        dir: @tmpDir
        ignoreFiles: ['^node_modules/']
      done()

  describe 'find', ->
    context 'top level file', ->
      beforeEach (done) ->
        @filePath = path.join(@tmpDir, 'a.coffee')
        fs.outputFile @filePath, '', (err) =>
          if err then return done err
          @fileFinder.find (@err, @files) => done()

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the file under prod', ->
        expect(@files).to.eql [@filePath]


    context 'file in subfolder', ->
      beforeEach (done) ->
        @filePath = path.join(@tmpDir, 'lib/a.coffee')
        fs.outputFile @filePath, '', (err) =>
          if err then return done err
          @fileFinder.find (@err, @files) => done()

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the file under prod', ->
        expect(@files).to.eql [@filePath]


    context 'file matching ignore regex', ->
      beforeEach (done) ->
        @filePath = path.join(@tmpDir, 'node_modules/a.coffee')
        fs.outputFile @filePath, '', (err) =>
          if err then return done err
          @fileFinder.find (@err, @files) => done()

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns no files', ->
        expect(@files).to.eql []
