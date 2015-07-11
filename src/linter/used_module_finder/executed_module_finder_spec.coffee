async = require 'async'
ExecutedModuleFinder = require './executed_module_finder'
fs = require 'fs-extra'
path = require 'path'
tmp = require 'tmp'


describe 'ExecutedModuleFinder', ->
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) => done err

  describe 'find', ->
    before ->
      @writePackagesAndFindModules = (packages, done) ->
        async.series [
          (taskDone) ->
            writePackage = ({filePath, content}, next) -> fs.outputJson filePath, content, next
            async.each packages, writePackage, taskDone
          (taskDone) =>
            new ExecutedModuleFinder(dir: @tmpDir).find (@err, @result) => taskDone()
        ], done

    beforeEach ->
      @packagePath = path.join @tmpDir, 'package.json'

    context 'no scripts', ->
      beforeEach (done) ->
        packages = [
          filePath: @packagePath
          content: {}
        ]
        @writePackagesAndFindModules packages, done

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns an empty result', ->
        expect(@result).to.eql []


    context 'script using module exectuable', ->
      beforeEach (done) ->
        packages = [
          filePath: @packagePath
          content: scripts: {test: 'mycha run'}
        ,
          filePath: path.join @tmpDir, 'node_modules', 'mycha', 'package.json'
          content: name: 'mycha', bin: {mycha: ''}
        ]
        @writePackagesAndFindModules packages, done

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the module under dev', ->
        expect(@result).to.eql [name: 'mycha', scripts: ['test']]


    context 'script using scoped module exectuable', ->
      beforeEach (done) ->
        packages = [
          filePath: @packagePath
          content: scripts: {test: 'mycha run'}
        ,
          filePath: path.join @tmpDir, 'node_modules', '@originate', 'mycha', 'package.json'
          content: name: '@originate/mycha', bin: {mycha: ''}
        ]
        @writePackagesAndFindModules packages, done

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the module under dev', ->
        expect(@result).to.eql [name: '@originate/mycha', scripts: ['test']]
