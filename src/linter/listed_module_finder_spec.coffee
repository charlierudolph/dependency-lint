getTmpDir = require '../../spec/support/get_tmp_dir'
path = require 'path'
ListedModuleFinder = require './listed_module_finder'
Promise = require 'bluebird'

writeJson = Promise.promisify require('fs-extra').writeJson


describe 'ListedModuleFinder', ->
  beforeEach ->
    @listedModuleFinder = new ListedModuleFinder
    getTmpDir().then (@tmpDir) =>

  describe 'find', ->
    beforeEach ->
      filePath = path.join @tmpDir, 'package.json'
      packageJsonData =
        dependencies:
          moduleA: '0.0.1'
        devDependencies:
          moduleB: '0.0.1'
      writeJson filePath, packageJsonData

    it 'resolves to the listed modules', ->
      expect(@listedModuleFinder.find(@tmpDir)).to.become
        dependencies: ['moduleA']
        devDependencies: ['moduleB']
