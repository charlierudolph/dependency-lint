async = require 'async'
ConfigurationLoader = require './configuration_loader'
csonParser = require 'cson-parser'
fs = require 'fs'
path = require 'path'
tmp = require 'tmp'


validUserConfigs = [
  extension: 'coffee'
  content: "module.exports = devFilePatterns: ['test/**/*']"
,
  extension: 'cson'
  content: csonParser.stringify(devFilePatterns: ['test/**/*'])
,
  extension: 'js'
  content: "module.exports = { devFilePatterns: ['test/**/*'] };"
,
  extension: 'json'
  content: JSON.stringify(devFilePatterns: ['test/**/*'])
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
      for {extension, content} in validUserConfigs
        do (extension, content) ->
          context "#{extension} file", ->
            beforeEach ->
              @configPath = path.join @tmpDir, "dependency-lint.#{extension}"

            context 'valid', ->
              beforeEach (done) ->
                async.series [
                  (next) => fs.writeFile @configPath, content, next
                  (next) => @configurationLoader.load (@err, @result) => next()
                ], done

              it 'does not return an error', ->
                expect(@err).to.not.exist

              it 'returns the default configuration merged with the user configuration', ->
                expect(@result).to.eql
                  allowUnused: []
                  devFilePatterns: ['test/**/*']
                  devScripts: ['lint', 'publish', 'test']
                  ignoreFilePatterns: ['**/node_modules/**/*']

            context 'invalid', ->
              beforeEach (done) ->
                async.series [
                  (next) => fs.writeFile @configPath, 'invalid', next
                  (next) => @configurationLoader.load (@err, @result) => next()
                ], done

              it 'returns an error', ->
                expect(@err).to.exist
                expect(@err.toString()).to.include @configPath

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
          ignoreFilePatterns: ['**/node_modules/**/*']
