import ExecutedModuleFinder from './executed_module_finder';
import { outputFile } from 'fs-extra';
import getTmpDir from '../../../test/support/get_tmp_dir';
import path from 'path';
import fs from 'fs';
import { beforeEach, describe, it } from 'mocha';
import { expect } from 'chai';

const { mkdir, symlink } = fs.promises;

const examples = [
  {
    config: { shellScripts: { root: '' } },
    description: 'no scripts',
    expectedResult: [],
    packageJson: {},
  },
  {
    config: { shellScripts: { root: '' } },
    description: 'package.json script using module exectuable',
    expectedResult: [{ name: 'myModule', script: 'test' }],
    moduleConfig: {
      name: 'myModule',
      executableName: 'myModule',
    },
    packageJson: {
      scripts: { test: 'myModule --opt arg' },
    },
  },
  {
    config: { shellScripts: { root: '' } },
    description: 'package.json script using module named exectuable',
    expectedResult: [{ name: 'myModule', script: 'test' }],
    moduleConfig: {
      name: 'myModule',
      executableName: 'myExecutable',
    },
    packageJson: {
      scripts: { test: 'myExecutable --opt arg' },
    },
  },
  {
    config: { shellScripts: { root: '' } },
    description: 'package.json script using scoped module exectuable',
    expectedResult: [{ name: '@myOrganization/myModule', script: 'test' }],
    moduleConfig: {
      name: '@myOrganization/myModule',
      executableName: 'myExecutable',
    },
    packageJson: {
      scripts: { test: 'myExecutable --opt arg' },
    },
  },
  {
    config: { shellScripts: { root: '' } },
    description:
      'package.json script containing module executable in another word',
    expectedResult: [],
    moduleConfig: {
      name: 'myModule',
      executableName: 'myExecutable',
    },
    packageJson: {
      scripts: { test: 'othermyExecutable --opt arg' },
    },
  },
  {
    config: { shellScripts: { root: 'bin/*' } },
    description: 'shell script using module exectuable',
    expectedResult: [{ name: 'myModule', file: 'bin/test' }],
    file: {
      path: 'bin/test',
      content: 'myExecutable --opt arg',
    },
    moduleConfig: {
      name: 'myModule',
      executableName: 'myExecutable',
    },
    packageJson: {},
  },
];

describe('ExecutedModuleFinder', function() {
  beforeEach(async function() {
    this.tmpDir = await getTmpDir();
  });

  describe('find', () =>
    examples.forEach(function(example) {
      const {
        config,
        description,
        expectedResult,
        file,
        moduleConfig,
        packageJson,
      } = example;

      describe(description, function() {
        beforeEach(async function() {
          if (moduleConfig) {
            const binPath = path.join(
              this.tmpDir,
              'node_modules',
              '.bin',
              moduleConfig.executableName
            );
            const linkPath = path.join(
              '..',
              moduleConfig.name,
              'path/to/executable'
            );
            await mkdir(path.dirname(binPath), { recursive: true });
            await symlink(linkPath, binPath);
            await outputFile(path.join(binPath, '..', linkPath), '');
          }
          if (file) {
            const fullPath = path.join(this.tmpDir, file.path);
            await outputFile(fullPath, file.content);
          }
          const finder = new ExecutedModuleFinder(config);
          this.result = await finder.find({ dir: this.tmpDir, packageJson });
        });

        it('returns the executed modules', function() {
          expect(this.result).to.eql(expectedResult);
        });
      });
    }));
});
