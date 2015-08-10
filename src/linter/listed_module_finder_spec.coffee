getTmpDir = require '../../spec/support/get_tmp_dir'
path = require 'path'
ListedModuleFinder = require './listed_module_finder'
Promise = require 'bluebird'

writeJson = Promise.promisify require('fs-extra').writeJson


describe 'ListedModuleFinder', ->
  beforeEach ->
    @listedModuleFinder = new ListedModuleFinder
    getTmpDir().save @, 'tmpDir'

  describe 'find', ->
    beforeEach ->
      filePath = path.join @tmpDir, 'package.json'
      packageJsonData =
        dependencies:
          moduleA: '0.0.1'
        devDependencies:
          moduleB: '0.0.1'
      writeJson filePath, packageJsonData
        .then => @listedModuleFinder.find(@tmpDir).save @, 'result', 'err'

    it 'does not return an error', ->
      expect(@err).to.not.exist

    it 'returns the listed modules', ->
      expect(@result).to.eql dependencies: ['moduleA'], devDependencies: ['moduleB']
