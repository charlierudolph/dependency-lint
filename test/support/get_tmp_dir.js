const Promise = require('bluebird');
const tmp = require('tmp');
const tmpDir = Promise.promisify(tmp.dir);
module.exports = () => tmpDir({ unsafeCleanup: true });
