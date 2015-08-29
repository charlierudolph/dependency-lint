async = require 'async'
ExecutedModuleFinder = require './executed_module_finder'
fsExtra = require 'fs-extra'
path = require 'path'
tmp = require 'tmp'


examples = [
  description: 'dependency not installed'
  expectedError: Error '''
    The following modules are listed in your `package.json` but are not installed.
      myModule
    All modules need to be installed to properly check for the usage of a module's executables.
    '''
  packageJson:
    dependencies: {myModule: '0.0.1'}
,
  description: 'devDependency not installed'
  expectedError: Error '''
    The following modules are listed in your `package.json` but are not installed.
      myModule
    All modules need to be installed to properly check for the usage of a module's executables.
    '''
  packageJson:
    devDependencies: {myModule: '0.0.1'}
,
  description: 'no scripts'
  expectedResult: []
  packageJson: {}
,
  description: 'script using module exectuable'
  expectedResult: [name: 'myModule', script: 'test']
  nodeModule:
    name: 'myModule'
    executable: 'myExecutable'
  packageJson:
    dependencies: {myModule: '0.0.1'}
    scripts: {test: 'myExecutable --opt arg'}

,
  description: 'script using scoped module exectuable'
  expectedResult: [name: '@myOrganization/myModule', script: 'test']
  nodeModule:
    name: '@myOrganization/myModule'
    executable: 'myExecutable'
  packageJson:
    dependencies: {'@myOrganization/myModule': '0.0.1'}
    scripts: {test: 'myExecutable --opt arg'}
]


describe 'ExecutedModuleFinder', ->
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) => done err

  describe 'find', ->
    examples.forEach ({description, expectedError, expectedResult, nodeModule, packageJson}) ->
      context description, ->
        beforeEach (done) ->
          actions = []
          packageJsonPath = path.join @tmpDir, 'package.json'
          actions.push (next) -> fsExtra.outputJson packageJsonPath, packageJson, next
          if nodeModule
            nodeModulesPath = path.join @tmpDir, 'node_modules'
            nodeModulesBinPath = path.join nodeModulesPath, '.bin'
            executablePath = path.join nodeModulesPath, nodeModule.name, 'path', 'to', 'executable'
            actions.push (next) -> fsExtra.outputFile executablePath, '', next
            actions.push (next) ->
              src = path.relative nodeModulesBinPath, executablePath
              dest = path.join nodeModulesBinPath, nodeModule.executable
              fsExtra.ensureSymlink src, dest, next
          actions.push (next) => new ExecutedModuleFinder().find @tmpDir, (@err, @result) => next()
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
