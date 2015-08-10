ConfigurationLoader = require './'
csonParser = require 'cson-parser'
path = require 'path'
Promise = require 'bluebird'
getTmpDir = require '../../spec/support/get_tmp_dir'

writeFile = Promise.promisify require('fs').writeFile


examples = [
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
  beforeEach ->
    @configurationLoader = new ConfigurationLoader
    getTmpDir().save @, 'tmpDir'

  context 'load', ->
    context 'with a user configuration', ->
      examples.forEach ({extension, invalidContent, validContent}) ->
        context "#{extension} file", ->
          beforeEach ->
            @configPath = path.join @tmpDir, "dependency-lint.#{extension}"

          context 'valid', ->
            beforeEach ->
              writeFile @configPath, validContent
                .then => @configurationLoader.load(@tmpDir).save @, 'result', 'err'

            it 'does not return an error', ->
              expect(@err).to.not.exist

            it 'returns the default configuration merged with the user configuration', ->
              expect(@result).to.eql
                allowUnused: []
                devFilePatterns: ['test/**/*']
                devScripts: ['lint', 'publish', 'test']
                ignoreFilePatterns: ['node_modules/**/*']

          context 'invalid', ->
            beforeEach ->
              writeFile @configPath, invalidContent
                .then => @configurationLoader.load(@tmpDir).save @, 'result', 'err'

            it 'returns an error', ->
              expect(@err).to.exist
              expect(@err.message).to.include @configPath

            it 'does not return a result', ->
              expect(@result).to.not.exist


    context 'without a user configuration', ->
      beforeEach ->
        @configurationLoader.load(@tmpDir).save @, 'result', 'err'

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the default configuration', ->
        expect(@result).to.eql
          allowUnused: []
          devFilePatterns: ['{features,spec,test}/**/*', '**/*_{spec,test}.{coffee,js}']
          devScripts: ['lint', 'publish', 'test']
          ignoreFilePatterns: ['node_modules/**/*']
