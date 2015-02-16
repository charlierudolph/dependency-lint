chai = require 'chai'
chaiFs = require 'chai-fs'

chai.use chaiFs
global.expect = chai.expect
