async = require 'async'
ConfigurationLoader = require './'
fs = require 'fs'
path = require 'path'
tmp = require 'tmp'


describe 'ConfigurationLoader', ->
  beforeEach (done) ->
    @configurationLoader = new ConfigurationLoader
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) => done err

  context 'load', ->
    context 'with a user configuration', ->
      beforeEach ->
        @configPath = path.join @tmpDir, 'dependency-lint.yml'

      context 'valid', ->
        beforeEach (done) ->
          validContent = '''
            requiredModules:
              files:
                dev:
                  - 'test/**/*'
            '''
          async.series [
            (next) => fs.writeFile @configPath, validContent, next
            (next) => @configurationLoader.load @tmpDir, (@err, @result) => next()
          ], done

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the default configuration merged with the user configuration', ->
          expect(@result).to.eql
            executedModules:
              npmScripts:
                dev: ['lint', 'publish', 'test', 'version']
            ignoreErrors:
              missing: []
              shouldBeDependency: []
              shouldBeDevDependency: []
              unused: []
            requiredModules:
              files:
                dev: ['test/**/*']
                ignore: ['node_modules/**/*']
                root: '**/*.js'
              stripLoaders: no
              transpilers: []

      context 'invalid', ->
        beforeEach (done) ->
          invalidContent = 'invalid: {'
          async.series [
            (next) => fs.writeFile @configPath, invalidContent, next
            (next) => @configurationLoader.load @tmpDir, (@err, @result) => next()
          ], done

        it 'returns an error', ->
          expect(@err).to.exist
          expect(@err.message).to.include @configPath

        it 'does not return a result', ->
          expect(@result).to.not.exist


  context 'without a user configuration', ->
    beforeEach (done) ->
      @configurationLoader.load @tmpDir, (@err, @config) => done()

    it 'does not return an error', ->
      expect(@err).to.not.exist

    it 'returns the default configuration', ->
      expect(@config).to.eql
        executedModules:
          npmScripts:
            dev: ['lint', 'publish', 'test', 'version']
        ignoreErrors:
          missing: []
          shouldBeDependency: []
          shouldBeDevDependency: []
          unused: []
        requiredModules:
          files:
            dev: ['{features,spec,test}/**/*', '**/*{.,_,-}{spec,test}.js']
            ignore: ['node_modules/**/*']
            root: '**/*.js'
          stripLoaders: no
          transpilers: []
