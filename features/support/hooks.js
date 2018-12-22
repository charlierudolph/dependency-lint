import { addToJsonFile } from '../support/file_helpers';
import getTmpDir from '../../test/support/get_tmp_dir';
import path from 'path';
import { Before, After } from 'cucumber';
import { expect } from 'chai';

Before(async function() {
  this.tmpDir = await getTmpDir();
  await addToJsonFile(path.join(this.tmpDir, 'package.json'), {});
});

After(function() {
  if (!this.errorExpected) {
    expect(this.error).to.not.exist();
    expect(this.stderr).to.be.empty();
  }
});
