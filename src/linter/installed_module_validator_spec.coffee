fsExtra = require 'fs-extra'
getTmpDir = require '../../spec/support/get_tmp_dir'
InstalledModuleValidator = require './installed_module_validator'
path = require 'path'
Promise = require 'bluebird'


{coroutine} = Promise
outputJson = Promise.promisify fsExtra.outputJson
writeJson = Promise.promisify fsExtra.writeJson


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
,
  description: 'dependency not installed through registry'
  installedModules: [
    name: 'myModule'
    version: '1.0.0'
  ]
  packageJson:
    dependencies:
      myModule: 'git+ssh://git@host:myOrganization/myModule.git#1.0.0"'
,
  description: 'devDependency not installed through registry'
  installedModules: [
    name: 'myModule'
    version: '1.0.0'
  ]
  packageJson:
    devDependencies:
      myModule: 'git+ssh://git@host:myOrganization/myModule.git#1.0.0"'
]


describe 'InstalledModuleValidator', ->
  beforeEach ->
    @installedModuleValidator = new InstalledModuleValidator

  describe 'validate', ->
    beforeEach coroutine ->
      @tmpDir = yield getTmpDir()

    examples.forEach ({description, expectedErrorMessage, packageJson, installedModules}) ->
      context description, ->
        beforeEach coroutine ->
          promises = []
          packageJsonPath = path.join @tmpDir, 'package.json'
          promises.push writeJson packageJsonPath, packageJson
          if installedModules
            installedModules.forEach ({name, version}) =>
              packageJsonPath = path.join @tmpDir, 'node_modules', name, 'package.json'
              promises.push outputJson packageJsonPath, {name, version}
          yield Promise.all promises

          try
            yield @installedModuleValidator.validate {dir: @tmpDir, packageJson}
          catch error
            @error = error

        if expectedErrorMessage
          it 'returns the expected error', ->
            expect(@error.message).to.eql expectedErrorMessage

        else
          it 'does not yield an error', ->
            expect(@error).to.not.exist
