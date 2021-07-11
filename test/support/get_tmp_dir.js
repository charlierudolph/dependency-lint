const Promise = require('bluebird');
const tmp = require('tmp');
const { realpath } = require('fs').promises;
const tmpDir = Promise.promisify(tmp.dir);
module.exports = async () => {
  const dir = await tmpDir({ unsafeCleanup: true });
  return realpath(dir);
};
