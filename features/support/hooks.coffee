{addToJsonFile} = require '../support/json_helpers'
path = require 'path'
getTmpDir = require '../../spec/support/get_tmp_dir'


module.exports = ->

  @Before ->
    getTmpDir()
      .save @, 'tmpDir'
      .then => addToJsonFile path.join(@tmpDir, 'package.json'), {}

  @After ->
    unless @errorExpected
      expect(@error).to.not.exist
      expect(@stderr).to.be.empty
