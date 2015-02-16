{expect} = require 'chai'
fs = require 'fs-extra'
path = require 'path'
tmp = require 'tmp'


module.exports = ->

  @Before (done) ->
    tmp.dir {unsafeCleanup: yes}, (err, @tmpDir) =>
      if err then return done err
      fs.outputJson path.join(@tmpDir, 'package.json'), {}, done


  @After (done) ->
    unless @errorExpected
      expect(@error).to.not.exist
      expect(@stderr).to.be.empty
    done()
