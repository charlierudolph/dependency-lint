async = require 'async'
fsExtra = require 'fs-extra'
path = require 'path'
ListedModuleFinder = require './listed_module_finder'
tmp = require 'tmp'


describe 'ListedModuleFinder', ->
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) => done err

  describe 'find', ->
    beforeEach (done) ->
      filePath = path.join @tmpDir, 'package.json'
      packageJsonData =
        dependencies:
          moduleA: '0.0.1'
        devDependencies:
          moduleB: '0.0.1'
      async.series [
        (next) -> fsExtra.writeJson filePath, packageJsonData, next
        (next) => new ListedModuleFinder(dir: @tmpDir).find (@err, @result) => next()
      ], done

    it 'does not return an error', ->
      expect(@err).to.not.exist

    it 'returns the listed modules', ->
      expect(@result).to.eql dependencies: ['moduleA'], devDependencies: ['moduleB']
