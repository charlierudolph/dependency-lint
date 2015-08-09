async = require 'async'
ExecutedModuleFinder = require './executed_module_finder'
fs = require 'fs-extra'
path = require 'path'
tmp = require 'tmp'


examples = [
  description: 'dependency not installed'
  expectedError: Error '''
    The following modules are listed in your `package.json` but are not installed.
      mycha
    All modules need to be installed to properly check for the usage of a module's executables.
    '''
  packages: [
    dir: '.'
    content: {dependencies: {mycha: '0.0.1'}}
  ]
,
  description: 'devDependency not installed'
  expectedError: Error '''
    The following modules are listed in your `package.json` but are not installed.
      mycha
    All modules need to be installed to properly check for the usage of a module's executables.
    '''
  packages: [
    dir: '.'
    content: {devDependencies: {mycha: '0.0.1'}}
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
  expectedResult: [name: 'mycha', scripts: ['test']]
  packages: [
    dir: '.'
    content: {dependencies: {mycha: '0.0.1'}, scripts: {test: 'mycha run'}}
  ,
    dir: 'node_modules/mycha'
    content: {name: 'mycha', bin: {mycha: ''}}
  ]
,
  description: 'script using scoped module exectuable'
  expectedResult: [name: '@originate/mycha', scripts: ['test']]
  packages: [
    dir: '.'
    content: {dependencies: {'@originate/mycha': '0.0.1'}, scripts: {test: 'mycha run'}}
  ,
    dir: 'node_modules/@originate/mycha'
    content: {name: '@originate/mycha', bin: {mycha: ''}}
  ]
]


describe 'ExecutedModuleFinder', ->
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) => done err

  describe 'find', ->
    examples.forEach ({description, expectedError, expectedResult, packages}) ->
      context description, ->
        beforeEach (done) ->
          async.series [
            (taskDone) =>
              writePackage = ({dir, content}, next) =>
                filePath = path.join @tmpDir, dir, 'package.json'
                fs.outputJson filePath, content, next
              async.each packages, writePackage, taskDone
            (taskDone) =>
              new ExecutedModuleFinder().find @tmpDir, (@err, @result) => taskDone()
          ], done

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
