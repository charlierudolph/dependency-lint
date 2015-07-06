async = require 'async'
{expect} = require 'chai'
fsExtra = require 'fs-extra'
path = require 'path'
tmp = require 'tmp'


module.exports = ->

  @Before (done) ->
    async.series [
      (next) =>
        tmp.dir {unsafeCleanup: yes}, (err, @tmpDir) => next err
      (next) =>
        fsExtra.writeJson path.join(@tmpDir, 'package.json'), {}, next
    ], done


  @After (done) ->
    unless @errorExpected
      expect(@error).to.not.exist
      expect(@stderr).to.be.empty
    done()
