process.env.NODE_ENV = 'test'

chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'
chai.use require 'chai-as-promised'

global.chai = chai
global.expect = chai.expect
global.sinon = sinon
