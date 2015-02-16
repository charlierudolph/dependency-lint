ConfigurationLoader = require './configuration_loader'
fs = require 'fs-extra'
path = require 'path'
tmp = require 'tmp'


describe 'ConfigurationLoader', ->
  beforeEach (done) ->
    tmp.dir {unsafeCleanup: true}, (err, @tmpDir) =>
      if err then return done err
      @configurationLoader = new ConfigurationLoader {dir: @tmpDir}
      done()

  context 'load', ->
    context 'with a user configuration', ->
      beforeEach (done) ->
        userConfig = {devFiles: ['^test/']}
        fs.outputJson path.join(@tmpDir, 'dependency-lint.json'), userConfig, (err) =>
          if err then return done err
          @configurationLoader.load (@err, @config) => done()

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the default configuration merged with the user configuration', ->
        expect(@config).to.eql
          allowUnused: []
          devFiles: ['^test/']
          devScripts: ['publish', 'test']
          ignoreFiles: ['^node_modules/']

    context 'without a user configuration', ->
      beforeEach (done) ->
        @configurationLoader.load (@err, @config) => done()

      it 'does not return an error', ->
        expect(@err).to.not.exist

      it 'returns the default configuration', ->
        expect(@config).to.eql
          allowUnused: []
          devFiles: ['^(features|spec|test)/', '_(spec|test).(coffee|js)$']
          devScripts: ['publish', 'test']
          ignoreFiles: ['^node_modules/']
