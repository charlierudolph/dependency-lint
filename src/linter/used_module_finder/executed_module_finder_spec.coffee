ExecutedModuleFinder = require './executed_module_finder'
fsExtra = require 'fs-extra'
getTmpDir = require '../../../spec/support/get_tmp_dir'
path = require 'path'
Promise = require 'bluebird'


{coroutine} = Promise
ensureSymlink = Promise.promisify fsExtra.ensureSymlink
outputJson = Promise.promisify fsExtra.outputJson
outputFile = Promise.promisify fsExtra.outputFile


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
  beforeEach coroutine ->
    @tmpDir = yield getTmpDir()

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
        beforeEach coroutine ->
          promises = []
          if modulePackageJson
            filePath = path.join @tmpDir, 'node_modules', modulePackageJson.name, 'package.json'
            promises.push outputJson(filePath, modulePackageJson)
          if file
            promises.push outputFile(path.join(@tmpDir, file.path), file.content)
          yield Promise.all promises
          finder = new ExecutedModuleFinder config
          @result = yield finder.find {dir: @tmpDir, packageJson}

        it 'returns the executed modules', ->
          expect(@result).to.eql expectedResult
