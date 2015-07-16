async = require 'async'
ExecutedModuleFinder = require './executed_module_finder'
fs = require 'fs-extra'
path = require 'path'
tmp = require 'tmp'


describe 'ExecutedModuleFinder', ->
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) => done err

  describe 'find', ->
    beforeEach ->
      @packagePath = path.join @tmpDir, 'package.json'
      @findModules = (done) =>
        @executedModulesFinder = new ExecutedModuleFinder dir: @tmpDir
        @executedModulesFinder.find (@err, @result) => done()

    context 'no scripts', ->
      beforeEach (done) ->
        async.series [
          (next) => fs.outputJson @packagePath, {}, next
          (next) => new ExecutedModuleFinder(dir: @tmpDir).find (@err, @result) => next()
        ], done

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns an empty result', ->
        expect(@result).to.eql []


    context 'script using module exectuable', ->
      beforeEach (done) ->
        packageContent = scripts: {test: 'mycha run'}
        modulePackagePath = path.join @tmpDir, 'node_modules', 'mycha', 'package.json'
        modulePackageContent = name: 'mycha', bin: {mycha: ''}
        async.auto {
          outputPackage: (next) =>
            fs.outputJson @packagePath, packageContent, next
          outputModulePackage: (next) ->
            fs.outputJson modulePackagePath, modulePackageContent, next
          findModules: ['outputPackage', 'outputModulePackage', (next) =>
            new ExecutedModuleFinder(dir: @tmpDir).find (@err, @result) => next()
          ]
        }, done

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the module under dev', ->
        expect(@result).to.eql [name: 'mycha', scripts: ['test']]


    context 'script using scoped module exectuable', ->
      beforeEach (done) ->
        packageContent = scripts: {test: 'mycha run'}
        modulePackagePath = path.join @tmpDir, 'node_modules', '@originate', 'mycha', 'package.json'
        modulePackageContent = name: '@originate/mycha', bin: {mycha: ''}
        async.auto {
          outputPackage: (next) =>
            fs.outputJson @packagePath, packageContent, next
          outputModulePackage: (next) ->
            fs.outputJson modulePackagePath, modulePackageContent, next
          findModules: ['outputPackage', 'outputModulePackage', (next) =>
            new ExecutedModuleFinder(dir: @tmpDir).find (@err, @result) => next()
          ]
        }, done

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the module under dev', ->
        expect(@result).to.eql [name: '@originate/mycha', scripts: ['test']]
