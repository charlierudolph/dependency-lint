import { outputJson, writeJson } from 'fs-extra';
import getTmpDir from '../../test/support/get_tmp_dir';
import InstalledModuleValidator from './installed_module_validator';
import path from 'path';
import Promise from 'bluebird';
import { beforeEach, describe, it } from 'mocha';
import { expect } from 'chai';

const examples = [
  {
    description: 'dependency not installed',
    expectedErrorMessage: `\
The following modules listed in your \`package.json\` have issues:
  myModule (not installed)
All modules need to be installed with the correct semantic version
to properly check for the usage of a module's executables.\
`,
    packageJson: {
      dependencies: { myModule: '^1.0.0' },
    },
  },
  {
    description: 'devDependency not installed',
    expectedErrorMessage: `\
The following modules listed in your \`package.json\` have issues:
  myModule (not installed)
All modules need to be installed with the correct semantic version
to properly check for the usage of a module's executables.\
`,
    packageJson: {
      devDependencies: { myModule: '^1.0.0' },
    },
  },
  {
    description: 'dependency wrong version installed',
    expectedErrorMessage: `\
The following modules listed in your \`package.json\` have issues:
  myModule (installed: 2.0.0, listed: ^1.0.0)
All modules need to be installed with the correct semantic version
to properly check for the usage of a module's executables.\
`,
    installedModules: [
      {
        name: 'myModule',
        version: '2.0.0',
      },
    ],
    packageJson: {
      dependencies: { myModule: '^1.0.0' },
    },
  },
  {
    description: 'devDependency wrong version installed',
    expectedErrorMessage: `\
The following modules listed in your \`package.json\` have issues:
  myModule (installed: 2.0.0, listed: ^1.0.0)
All modules need to be installed with the correct semantic version
to properly check for the usage of a module's executables.\
`,
    installedModules: [
      {
        name: 'myModule',
        version: '2.0.0',
      },
    ],
    packageJson: {
      devDependencies: { myModule: '^1.0.0' },
    },
  },
  {
    description: 'dependency not installed through registry',
    installedModules: [
      {
        name: 'myModule',
        version: '1.0.0',
      },
    ],
    packageJson: {
      dependencies: {
        myModule: 'git+ssh://git@host:myOrganization/myModule.git#1.0.0"',
      },
    },
  },
  {
    description: 'devDependency not installed through registry',
    installedModules: [
      {
        name: 'myModule',
        version: '1.0.0',
      },
    ],
    packageJson: {
      devDependencies: {
        myModule: 'git+ssh://git@host:myOrganization/myModule.git#1.0.0"',
      },
    },
  },
  {
    description: 'validate the version specified in dependencies',
    installedModules: [
      {
        name: 'myModule',
        version: '0.9.1',
      },
    ],
    packageJson: {
      dependencies: {
        myModule: '0.9.1',
      },
      devDependencies: {
        myModule: '1.0.0',
      },
    },
  },
];

describe('InstalledModuleValidator', function() {
  beforeEach(function() {
    this.installedModuleValidator = new InstalledModuleValidator();
  });

  describe('validate', function() {
    beforeEach(async function() {
      this.tmpDir = await getTmpDir();
    });

    examples.forEach(
      ({ description, expectedErrorMessage, packageJson, installedModules }) =>
        describe(description, function() {
          beforeEach(async function() {
            const promises = [];
            let packageJsonPath = path.join(this.tmpDir, 'package.json');
            promises.push(writeJson(packageJsonPath, packageJson));
            if (installedModules) {
              installedModules.forEach(({ name, version }) => {
                packageJsonPath = path.join(
                  this.tmpDir,
                  'node_modules',
                  name,
                  'package.json'
                );
                promises.push(outputJson(packageJsonPath, { name, version }));
              });
            }
            await Promise.all(promises);

            try {
              await this.installedModuleValidator.validate({
                dir: this.tmpDir,
                packageJson,
              });
            } catch (error) {
              this.error = error;
            }
          });

          if (expectedErrorMessage) {
            it('returns the expected error', function() {
              expect(this.error.message).to.eql(expectedErrorMessage);
            });
          } else {
            it('does not yield an error', function() {
              expect(this.error).to.not.exist();
            });
          }
        })
    );
  });
});
