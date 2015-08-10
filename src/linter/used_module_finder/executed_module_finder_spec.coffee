ExecutedModuleFinder = require './executed_module_finder'
getTmpDir = require '../../../spec/support/get_tmp_dir'
path = require 'path'
Promise = require 'bluebird'

outputJson = Promise.promisify require('fs-extra').outputJson


examples = [
  description: 'dependency not installed'
  expectedError: Error '''
    The following modules are listed in your `package.json` but are not installed.
      myModule
    All modules need to be installed to properly check for the usage of a module's executables.
    '''
  packages: [
    dir: '.'
    content:
      dependencies: {myModule: '0.0.1'}
  ]
,
  description: 'devDependency not installed'
  expectedError: Error '''
    The following modules are listed in your `package.json` but are not installed.
      myModule
    All modules need to be installed to properly check for the usage of a module's executables.
    '''
  packages: [
    dir: '.'
    content:
      devDependencies: {myModule: '0.0.1'}
  ]
,
  description: 'no scripts'
  expectedResult: []
  packages: [
    dir: '.'
    content: {}
  ]
,
  description: 'script using module exectuable'
  expectedResult: [name: 'myModule', scripts: ['test']]
  packages: [
    dir: '.'
    content:
      dependencies: {myModule: '0.0.1'}
      scripts: {test: 'myExecutable --opt arg'}
  ,
    dir: 'node_modules/myModule'
    content:
      name: 'myModule'
      bin: {myExecutable: ''}
  ]
,
  description: 'script using scoped module exectuable'
  expectedResult: [name: '@myOrganization/myModule', scripts: ['test']]
  packages: [
    dir: '.'
    content:
      dependencies: {'@myOrganization/myModule': '0.0.1'}
      scripts: {test: 'myExecutable --opt arg'}
  ,
    dir: 'node_modules/@myOrganization/myModule'
    content:
      name: '@myOrganization/myModule'
      bin: {myExecutable: ''}
  ]
]


describe 'ExecutedModuleFinder', ->
  beforeEach ->
    @executedModuleFinder = new ExecutedModuleFinder
    getTmpDir().save @, 'tmpDir'

  describe 'find', ->
    examples.forEach ({description, expectedError, expectedResult, packages}) ->
      context description, ->
        beforeEach ->
          Promise.resolve packages
            .map ({dir, content}) =>
              filePath = path.join @tmpDir, dir, 'package.json'
              outputJson filePath, content
            .then => @executedModuleFinder.find(@tmpDir).save @, 'result', 'err'

        if expectedError
          it 'returns the expected error', ->
            expect(@err).to.eql expectedError

          it 'does not yield a result', ->
            expect(@result).to.not.exist

        else
          it 'does not yield an error', ->
            expect(@err).to.not.exist

          it 'returns the expected error', ->
            expect(@result).to.eql expectedResult
