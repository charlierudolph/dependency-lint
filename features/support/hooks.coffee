{addToJsonFile} = require '../support/file_helpers'
path = require 'path'
getTmpDir = require '../../spec/support/get_tmp_dir'


module.exports = ->

  @Before ->
    @tmpDir = yield getTmpDir()
    yield addToJsonFile path.join(@tmpDir, 'package.json'), {}

  @After ->
    unless @errorExpected
      expect(@error).to.not.exist
      expect(@stderr).to.be.empty
