async = require 'async'
fsExtra = require 'fs-extra'
InstalledModuleValidator = require './installed_module_validator'
path = require 'path'
tmp = require 'tmp'


examples = [
  description: 'dependency not installed'
  expectedErrorMessage: '''
    The following modules listed in your `package.json` have issues:
      myModule (not installed)
    All modules need to be installed with the correct semantic version
    to properly check for the usage of a module's executables.
    '''
  packageJson:
    dependencies: {myModule: '^1.0.0'}
,
  description: 'devDependency not installed'
  expectedErrorMessage: '''
    The following modules listed in your `package.json` have issues:
      myModule (not installed)
    All modules need to be installed with the correct semantic version
    to properly check for the usage of a module's executables.
    '''
  packageJson:
    devDependencies: {myModule: '^1.0.0'}
,
  description: 'dependency wrong version installed'
  expectedErrorMessage: '''
    The following modules listed in your `package.json` have issues:
      myModule (installed: 2.0.0, listed: ^1.0.0)
    All modules need to be installed with the correct semantic version
    to properly check for the usage of a module's executables.
    '''
  installedModules: [
    name: 'myModule'
    version: '2.0.0'
  ]
  packageJson:
    dependencies: {myModule: '^1.0.0'}
,
  description: 'devDependency wrong version installed'
  expectedErrorMessage: '''
    The following modules listed in your `package.json` have issues:
      myModule (installed: 2.0.0, listed: ^1.0.0)
    All modules need to be installed with the correct semantic version
    to properly check for the usage of a module's executables.
    '''
  installedModules: [
    name: 'myModule'
    version: '2.0.0'
  ]
  packageJson:
    devDependencies: {myModule: '^1.0.0'}
]


describe 'InstalledModuleValidator', ->
  beforeEach ->
    @installedModuleValidator = new InstalledModuleValidator

  describe 'validate', ->
    beforeEach (done) ->
      tmp.dir {unsafeCleanup: true}, (err, @tmpDir) => done err

    examples.forEach ({description, expectedErrorMessage, packageJson, installedModules}) ->
      context description, ->
        beforeEach (done) ->
          actions = []
          actions.push (next) =>
            packageJsonPath = path.join @tmpDir, 'package.json'
            fsExtra.writeJson packageJsonPath, packageJson, next
          if installedModules
            actions.push (next) =>
              iterator = ({name, version}, cb) =>
                packageJsonPath = path.join @tmpDir, 'node_modules', name, 'package.json'
                fsExtra.outputJson packageJsonPath, {name, version}, cb
              async.each installedModules, iterator, next
          actions.push (next) =>
            @installedModuleValidator.validate {dir: @tmpDir, packageJson}, (@err) => next()
          async.series actions, done

        if expectedErrorMessage
          it 'returns the expected error', ->
            expect(@err.message).to.eql expectedErrorMessage

        else
          it 'does not yield an error', ->
            expect(@err).to.not.exist
