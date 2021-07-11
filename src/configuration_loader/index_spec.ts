import ConfigurationLoader from './';
import { writeFile } from 'fs-extra';
import getTmpDir from '../../test/support/get_tmp_dir';
import path from 'path';
import { beforeEach, describe, it } from 'mocha';
import { expect } from 'chai';

describe('ConfigurationLoader', function() {
  beforeEach(async function() {
    this.configurationLoader = new ConfigurationLoader();
    this.tmpDir = await getTmpDir();
  });

  describe('load', function() {
    describe('with a user configuration', function() {
      beforeEach(function() {
        this.configPath = path.join(this.tmpDir, 'dependency-lint.yml');
      });

      describe('valid', function() {
        beforeEach(async function() {
          const validContent = `\
requiredModules:
  acornParseProps:
    ecmaVersion: 6
  files:
    dev:
      - 'test/**/*'\
`;
          await writeFile(this.configPath, validContent);
          this.result = await this.configurationLoader.load(this.tmpDir);
        });

        it('returns the user configuration merged into the default configuration', function() {
          expect(this.result).to.eql({
            executedModules: {
              npmScripts: {
                dev: ['lint', 'publish', 'test', 'version'],
              },
              shellScripts: {
                dev: [],
                ignore: [],
                root: '',
              },
            },
            ignoreErrors: {
              missing: [],
              shouldBeDependency: [],
              shouldBeDevDependency: [],
              unused: [],
            },
            requiredModules: {
              acornParseProps: { ecmaVersion: 6 },
              files: {
                dev: ['test/**/*'],
                ignore: ['node_modules/**/*'],
                root: '**/*.js',
              },
              stripLoaders: false,
              transpilers: [],
            },
          });
        });
      });

      describe('invalid', function() {
        beforeEach(async function() {
          const invalidContent = 'invalid: {';
          await writeFile(this.configPath, invalidContent);
          try {
            await this.configurationLoader.load(this.tmpDir);
          } catch (error) {
            this.error = error;
          }
        });

        it('errors with a message that includes the path to the config', function() {
          expect(this.error.message).to.include(this.configPath);
        });
      });
    });

    describe('without a user configuration', function() {
      beforeEach(async function() {
        this.result = await this.configurationLoader.load(this.tmpDir);
      });

      it('returns the default configuration', function() {
        expect(this.result).to.eql({
          executedModules: {
            npmScripts: {
              dev: ['lint', 'publish', 'test', 'version'],
            },
            shellScripts: {
              dev: [],
              ignore: [],
              root: '',
            },
          },
          ignoreErrors: {
            missing: [],
            shouldBeDependency: [],
            shouldBeDevDependency: [],
            unused: [],
          },
          requiredModules: {
            acornParseProps: {},
            files: {
              dev: ['{features,spec,test}/**/*', '**/*{.,_,-}{spec,test}.js'],
              ignore: ['node_modules/**/*'],
              root: '**/*.js',
            },
            stripLoaders: false,
            transpilers: [],
          },
        });
      });
    });
  });
});
