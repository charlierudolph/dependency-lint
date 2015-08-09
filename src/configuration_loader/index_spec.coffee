async = require 'async'
ConfigurationLoader = require './'
csonParser = require 'cson-parser'
fs = require 'fs'
path = require 'path'
tmp = require 'tmp'


userConfigs = [
  extension: 'coffee'
  invalidContent: 'invalid'
  validContent: '''
    module.exports =
      devFilePatterns: ['test/**/*']
    '''
,
  extension: 'cson'
  invalidContent: 'invalid'
  validContent: csonParser.stringify devFilePatterns: ['test/**/*']
,
  extension: 'js'
  invalidContent: 'invalid'
  validContent: '''
    module.exports = {
      devFilePatterns: ['test/**/*']
    };
    '''
,
  extension: 'json'
  invalidContent: 'invalid'
  validContent: JSON.stringify devFilePatterns: ['test/**/*']
,
  extension: 'yaml'
  invalidContent: 'invalid: {'
  validContent: '''
    devFilePatterns:
    - 'test/**/*'
    '''
,
  extension: 'yml'
  invalidContent: 'invalid: {'
  validContent: '''
    devFilePatterns:
    - 'test/**/*'
    '''
]


describe 'ConfigurationLoader', ->
  beforeEach (done) ->
    async.series [
      (next) =>
        tmp.dir {unsafeCleanup: true}, (err, @tmpDir) => next err
      (next) =>
        @configurationLoader = new ConfigurationLoader {dir: @tmpDir}
        next()
    ], done

  context 'load', ->
    context 'with a user configuration', ->
      for {extension, invalidContent, validContent} in userConfigs
        do (extension, invalidContent, validContent) ->
          context "#{extension} file", ->
            beforeEach ->
              @configPath = path.join @tmpDir, "dependency-lint.#{extension}"

            context 'valid', ->
              beforeEach (done) ->
                async.series [
                  (next) => fs.writeFile @configPath, validContent, next
                  (next) => @configurationLoader.load (@err, @result) => next()
                ], done

              it 'does not return an error', ->
                expect(@err).to.not.exist

              it 'returns the default configuration merged with the user configuration', ->
                expect(@result).to.eql
                  allowUnused: []
                  devFilePatterns: ['test/**/*']
                  devScripts: ['lint', 'publish', 'test']
                  ignoreFilePatterns: ['node_modules/**/*']

            context 'invalid', ->
              beforeEach (done) ->
                async.series [
                  (next) => fs.writeFile @configPath, invalidContent, next
                  (next) => @configurationLoader.load (@err, @result) => next()
                ], done

              it 'returns an error', ->
                expect(@err).to.exist
                expect(@err.message).to.include @configPath

              it 'does not return a result', ->
                expect(@result).to.not.exist


    context 'without a user configuration', ->
      beforeEach (done) ->
        @configurationLoader.load (@err, @config) => done()

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the default configuration', ->
        expect(@config).to.eql
          allowUnused: []
          devFilePatterns: ['{features,spec,test}/**/*', '**/*_{spec,test}.{coffee,js}']
          devScripts: ['lint', 'publish', 'test']
          ignoreFilePatterns: ['node_modules/**/*']
