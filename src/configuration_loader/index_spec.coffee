ConfigurationLoader = require './'
fs = require 'fs'
getTmpDir = require '../../spec/support/get_tmp_dir'
path = require 'path'
Promise = require 'bluebird'


{coroutine} = Promise
writeFile = Promise.promisify fs.writeFile


describe 'ConfigurationLoader', ->
  beforeEach coroutine ->
    @configurationLoader = new ConfigurationLoader
    @tmpDir = yield getTmpDir()

  context 'load', ->
    context 'with a user configuration', ->
      beforeEach ->
        @configPath = path.join @tmpDir, 'dependency-lint.yml'

      context 'valid', ->
        beforeEach coroutine ->
          validContent = '''
            requiredModules:
              acornParseProps:
                ecmaVersion: 6
              files:
                dev:
                  - 'test/**/*'
            '''
          yield writeFile @configPath, validContent
          @result = yield @configurationLoader.load @tmpDir


        it 'returns the user configuration merged into the default configuration', ->
          expect(@result).to.eql
            executedModules:
              npmScripts:
                dev: ['lint', 'publish', 'test', 'version']
              shellScripts:
                dev: []
                ignore: []
                root: ''
            ignoreErrors:
              missing: []
              shouldBeDependency: []
              shouldBeDevDependency: []
              unused: []
            requiredModules:
              acornParseProps: {ecmaVersion: 6}
              files:
                dev: ['test/**/*']
                ignore: ['node_modules/**/*']
                root: '**/*.js'
              stripLoaders: no
              transpilers: []

      context 'invalid', ->
        beforeEach coroutine ->
          invalidContent = 'invalid: {'
          yield writeFile @configPath, invalidContent
          try
            yield @configurationLoader.load @tmpDir
          catch error
            @error = error

        it 'errors with a message that includes the path to the config', ->
          expect(@error.message).to.include @configPath


    context 'without a user configuration', ->
      beforeEach coroutine ->
        @result = yield @configurationLoader.load @tmpDir

      it 'returns the default configuration', ->
        expect(@result).to.eql
          executedModules:
            npmScripts:
              dev: ['lint', 'publish', 'test', 'version']
            shellScripts:
              dev: []
              ignore: []
              root: ''
          ignoreErrors:
            missing: []
            shouldBeDependency: []
            shouldBeDevDependency: []
            unused: []
          requiredModules:
            acornParseProps: {}
            files:
              dev: ['{features,spec,test}/**/*', '**/*{.,_,-}{spec,test}.js']
              ignore: ['node_modules/**/*']
              root: '**/*.js'
            stripLoaders: no
            transpilers: []
