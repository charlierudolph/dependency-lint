chai = require 'chai'
chai.use require 'sinon-chai'
chai.use require 'chai-as-promised'
sinon = require 'sinon'


global.expect = chai.expect
global.sinon = sinon
