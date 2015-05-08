chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

global.expect = chai.expect
global.sinon = sinon

process.env.NODE_ENV = 'test'
