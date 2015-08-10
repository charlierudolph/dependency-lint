chai = require 'chai'
chai.use require 'sinon-chai'
Promise = require 'bluebird'
sinon = require 'sinon'


global.expect = chai.expect
global.sinon = sinon


Promise::save = (context, saveThenAs, saveCatchAs) ->
  result = @
  if saveThenAs
    result = result.then (arg) -> context[saveThenAs] = arg
  if saveCatchAs
    result = result.catch (arg) -> context[saveCatchAs] = arg
  result
