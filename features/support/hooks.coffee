{addToJsonFile} = require '../support/file_helpers'
{coroutine} = require 'bluebird'
getTmpDir = require '../../spec/support/get_tmp_dir'
isGenerator = require 'is-generator'
path = require 'path'


module.exports = ->

  @Before ->
    @tmpDir = yield getTmpDir()
    yield addToJsonFile path.join(@tmpDir, 'package.json'), {}

  @After ->
    unless @errorExpected
      expect(@error).to.not.exist
      expect(@stderr).to.be.empty

  @setDefinitionFunctionWrapper (fn) ->
    if isGenerator.fn(fn)
      coroutine fn
    else
      fn
