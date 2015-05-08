async = require 'async'
ExecutedModuleFinder = require './executed_module_finder'
fs = require 'fs-extra'
path = require 'path'
tmp = require 'tmp'


describe 'ExecutedModuleFinder', ->
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) =>
      if err then return done err
      @packagePath = path.join @tmpDir, 'package.json'
      @executablesPath = path.join @tmpDir, 'node_modules', '.bin'
      fs.mkdirp @executablesPath, done

  describe 'find', ->
    context 'no scripts', ->
      beforeEach (done) ->
        fs.outputJson @packagePath, {}, (err) =>
          if err then return done err
          @executedModulesFinder = new ExecutedModuleFinder dir: @tmpDir
          @executedModulesFinder.find (@err, @result) => done()

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns an empty result', ->
        expect(@result).to.eql []


    context 'script using module exectuable', ->
      beforeEach (done) ->
        async.parallel [
          (taskDone) => fs.outputJson @packagePath, {scripts: {test: 'mycha run'}}, taskDone
          (taskDone) =>
            fs.outputJson(
              path.join(@tmpDir, 'node_modules', 'mycha', 'package.json'),
              name: 'mycha', bin: {mycha: ''}
              taskDone
            )
        ], (err) =>
          if err then return done err
          @executedModulesFinder = new ExecutedModuleFinder dir: @tmpDir
          @executedModulesFinder.find (@err, @result) => done()

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the module under dev', ->
        expect(@result).to.eql [name: 'mycha', scripts: ['test']]

    context 'script using scoped module exectuable', ->
      beforeEach (done) ->
        async.parallel [
          (taskDone) => fs.outputJson @packagePath, {scripts: {test: 'mycha run'}}, taskDone
          (taskDone) =>
            fs.outputJson(
              path.join(@tmpDir, 'node_modules', '@originate', 'mycha', 'package.json'),
              name: '@originate/mycha', bin: {mycha: ''}
              taskDone
            )
        ], (err) =>
          if err then return done err
          @executedModulesFinder = new ExecutedModuleFinder dir: @tmpDir
          @executedModulesFinder.find (@err, @result) => done()

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the module under dev', ->
        expect(@result).to.eql [name: '@originate/mycha', scripts: ['test']]
