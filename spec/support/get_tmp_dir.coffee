Promise = require 'bluebird'

tmpDir = Promise.promisify require('tmp').dir


getTmpDir = ->
  tmpDir(unsafeCleanup: yes).spread (tmpDir) -> tmpDir


module.exports = getTmpDir
