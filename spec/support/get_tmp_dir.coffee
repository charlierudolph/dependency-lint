Promise = require 'bluebird'
tmp = require('tmp')


tmpDir = Promise.promisify tmp.dir


getTmpDir = -> tmpDir(unsafeCleanup: yes)


module.exports = getTmpDir
