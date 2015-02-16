{expect} = require 'chai'
tmp = require 'tmp'


module.exports = ->

  @Before (done) ->
    tmp.dir {unsafeCleanup: yes}, (err, @tmpDir) => done err


  @After (done) ->
    unless @errorExpected
      expect(@error).to.not.exist
      expect(@stderr).to.be.empty
    done()
