ConfigurationLoader = require './configuration_loader'
fs = require 'fs'
fsExtra = require 'fs-extra'
fsCson = require 'fs-cson'
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
      context 'coffee file', ->
        beforeEach (done) ->
          src = "module.exports = devFilePatterns: ['test/**/*']"
          fs.writeFile path.join(@tmpDir, 'dependency-lint.coffee'), src, (err) =>
            if err then return done err
            @configurationLoader.load (@err, @config) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the default configuration merged with the user configuration', ->
          expect(@config).to.eql
            allowUnused: []
            devFilePatterns: ['test/**/*']
            devScripts: ['lint', 'publish', 'test']
            ignoreFilePatterns: ['**/node_modules/**/*']

      context 'cson file', ->
        beforeEach (done) ->
          userConfig = devFilePatterns: ['test/**/*']
          fsCson.writeFile path.join(@tmpDir, 'dependency-lint.cson'), userConfig, (err) =>
            if err then return done err
            @configurationLoader.load (@err, @config) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the default configuration merged with the user configuration', ->
          expect(@config).to.eql
            allowUnused: []
            devFilePatterns: ['test/**/*']
            devScripts: ['lint', 'publish', 'test']
            ignoreFilePatterns: ['**/node_modules/**/*']

      context 'js file', ->
        beforeEach (done) ->
          src = "module.exports = { devFilePatterns: ['test/**/*'] };"
          fs.writeFile path.join(@tmpDir, 'dependency-lint.js'), src, (err) =>
            if err then return done err
            @configurationLoader.load (@err, @config) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the default configuration merged with the user configuration', ->
          expect(@config).to.eql
            allowUnused: []
            devFilePatterns: ['test/**/*']
            devScripts: ['lint', 'publish', 'test']
            ignoreFilePatterns: ['**/node_modules/**/*']

      context 'json file', ->
        beforeEach (done) ->
          userConfig = devFilePatterns: ['test/**/*']
          fsExtra.writeJson path.join(@tmpDir, 'dependency-lint.json'), userConfig, (err) =>
            if err then return done err
            @configurationLoader.load (@err, @config) => done()

        it 'does not return an error', ->
          expect(@err).to.not.exist

        it 'returns the default configuration merged with the user configuration', ->
          expect(@config).to.eql
            allowUnused: []
            devFilePatterns: ['test/**/*']
            devScripts: ['lint', 'publish', 'test']
            ignoreFilePatterns: ['**/node_modules/**/*']

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
