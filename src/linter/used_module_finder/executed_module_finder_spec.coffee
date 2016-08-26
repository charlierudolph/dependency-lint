async = require 'async'
ExecutedModuleFinder = require './executed_module_finder'
fsExtra = require 'fs-extra'
path = require 'path'
tmp = require 'tmp'


examples = [
  config: {shellScripts: {root: ''}}
  description: 'no scripts'
  expectedResult: []
  packageJson: {}
,
  config: {shellScripts: {root: ''}}
  description: 'package.json script using module exectuable'
  expectedResult: [name: 'myModule', script: 'test']
  modulePackageJson:
    name: 'myModule'
    bin: 'path/to/executable'
  packageJson:
    scripts: {test: 'myModule --opt arg'}
,
  config: {shellScripts: {root: ''}}
  description: 'package.json script using module named exectuable'
  expectedResult: [name: 'myModule', script: 'test']
  modulePackageJson:
    name: 'myModule'
    bin: myExecutable: 'path/to/executable'
  packageJson:
    scripts: {test: 'myExecutable --opt arg'}
,
  config: {shellScripts: {root: ''}}
  description: 'package.json script using scoped module exectuable'
  expectedResult: [name: '@myOrganization/myModule', script: 'test']
  modulePackageJson:
    name: '@myOrganization/myModule'
    bin: myExecutable: 'path/to/executable'
  packageJson:
    scripts: {test: 'myExecutable --opt arg'}
,
  config: {shellScripts: {root: ''}}
  description: 'package.json script containing module executable in another word'
  expectedResult: []
  modulePackageJson:
    name: 'myModule'
    bin: myExecutable: 'path/to/executable'
  packageJson:
    scripts: {test: 'othermyExecutable --opt arg'}
,
  config: {shellScripts: {root: 'bin/*'}}
  description: 'shell script using module exectuable'
  expectedResult: [name: 'myModule', file: 'bin/test']
  file:
    path: 'bin/test'
    content: 'myExecutable --opt arg'
  modulePackageJson:
    name: 'myModule'
    bin: myExecutable: 'path/to/executable'
  packageJson: {}
]


describe 'ExecutedModuleFinder', ->
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) => done err

  describe 'find', ->
    examples.forEach (example) ->
      {
        config
        description,
        expectedResult,
        file,
        modulePackageJson,
        packageJson
      } = example

      context description, ->
        beforeEach (done) ->
          actions = []
          if modulePackageJson
            actions.push (next) =>
              filePath = path.join @tmpDir, 'node_modules', modulePackageJson.name, 'package.json'
              fsExtra.outputJson filePath, modulePackageJson, next
          if file
            actions.push (next) =>
              fsExtra.outputFile path.join(@tmpDir, file.path), file.content, next
          actions.push (next) =>
            finder = new ExecutedModuleFinder config
            finder.find {dir: @tmpDir, packageJson}, (@err, @result) => next()
          async.series actions, done

        it 'does not yield an error', ->
          expect(@err).to.not.exist

        it 'returns the expected result', ->
          expect(@result).to.eql expectedResult
