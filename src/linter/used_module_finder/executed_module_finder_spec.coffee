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
  nodeModule:
    name: 'myModule'
    executable: 'myExecutable'
  packageJson:
    scripts: {test: 'myExecutable --opt arg'}
,
  config: {shellScripts: {root: ''}}
  description: 'package.json script using scoped module exectuable'
  expectedResult: [name: '@myOrganization/myModule', script: 'test']
  nodeModule:
    name: '@myOrganization/myModule'
    executable: 'myExecutable'
  packageJson:
    scripts: {test: 'myExecutable --opt arg'}
,
  config: {shellScripts: {root: 'bin/*'}}
  description: 'shell script using module exectuable'
  expectedResult: [name: 'myModule', file: 'bin/test']
  file:
    path: 'bin/test'
    content: 'myExecutable --opt arg'
  nodeModule:
    name: 'myModule'
    executable: 'myExecutable'
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
        expectedError,
        expectedResult,
        file,
        nodeModule,
        packageJson
      } = example

      context description, ->
        beforeEach (done) ->
          actions = []
          if nodeModule
            nodeModulesPath = path.join @tmpDir, 'node_modules'
            nodeModulesBinPath = path.join nodeModulesPath, '.bin'
            executablePath = path.join nodeModulesPath, nodeModule.name, 'path', 'to', 'executable'
            actions.push (next) -> fsExtra.outputFile executablePath, '', next
            actions.push (next) ->
              src = path.relative nodeModulesBinPath, executablePath
              dest = path.join nodeModulesBinPath, nodeModule.executable
              fsExtra.ensureSymlink src, dest, next
          if file
            actions.push (next) =>
              fsExtra.outputFile path.join(@tmpDir, file.path), file.content, next
          actions.push (next) =>
            finder = new ExecutedModuleFinder config
            finder.find {dir: @tmpDir, packageJson}, (@err, @result) => next()
          async.series actions, done

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
