import DependencyLinter from './dependency_linter';
import ERRORS from '../errors';
import { beforeEach, describe, it } from 'mocha';
import { expect } from 'chai';

describe('DependencyLinter', function() {
  beforeEach(function() {
    this.options = {
      executedModules: {
        npmScripts: {
          dev: ['test'],
        },
        shellScripts: {
          dev: [],
        },
      },
      ignoreErrors: {
        missing: [],
        shouldBeDependency: [],
        shouldBeDevDependency: [],
        unused: [],
      },
      requiredModules: {
        files: {
          dev: ['**/*_spec.js'],
        },
      },
    };

    this.input = {
      listedModules: { dependencies: [], devDependencies: [] },
      usedModules: [],
    };

    this.output = {
      dependencies: [],
      devDependencies: [],
    };

    this.expectOutputToMatch = function() {
      const dependencyLinter = new DependencyLinter(this.options);
      this.result = dependencyLinter.lint(this.input);
      expect(this.result).to.eql(this.output);
    };
  });

  describe('not used', function() {
    describe('not listed', function() {
      beforeEach(function() {
        const dependencyLinter = new DependencyLinter(this.options);
        this.result = dependencyLinter.lint(this.input);
      });

      it('returns nothing', function() {
        this.expectOutputToMatch();
      });
    });

    describe('listed as dependency', function() {
      beforeEach(function() {
        this.input.listedModules.dependencies.push('myModule');
      });

      describe('not ignored', function() {
        beforeEach(function() {
          this.output.dependencies.push({
            name: 'myModule',
            error: ERRORS.UNUSED,
            files: [],
            scripts: [],
          });
        });

        it('returns error: unused', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrors.unused.push('myModule');
          this.output.dependencies.push({
            name: 'myModule',
            error: ERRORS.UNUSED,
            errorIgnored: true,
            files: [],
            scripts: [],
          });
        });

        it('returns ignored error: unused', function() {
          this.expectOutputToMatch();
        });
      });
    });

    describe('listed as devDependency', function() {
      beforeEach(function() {
        this.input.listedModules.devDependencies.push('myModule');
      });

      describe('not ignored', function() {
        beforeEach(function() {
          this.output.devDependencies.push({
            name: 'myModule',
            error: ERRORS.UNUSED,
            files: [],
            scripts: [],
          });
        });

        it('returns error: unused', function() {
          this.expectOutputToMatch();
        });
      });

      describe('on allowed unused list', function() {
        beforeEach(function() {
          this.options.ignoreErrors.unused.push('myModule');
          this.output.devDependencies.push({
            name: 'myModule',
            error: ERRORS.UNUSED,
            errorIgnored: true,
            files: [],
            scripts: [],
          });
        });

        it('returns ignored error: unused', function() {
          this.expectOutputToMatch();
        });
      });
    });
  });

  describe('used as a dependency', function() {
    beforeEach(function() {
      this.input.usedModules.push({
        name: 'myModule',
        files: ['server.js'],
        scripts: [],
      });
    });

    describe('not listed', function() {
      describe('not ignored', function() {
        beforeEach(function() {
          this.output.dependencies.push({
            name: 'myModule',
            files: ['server.js'],
            scripts: [],
            error: ERRORS.MISSING,
          });
        });

        it('returns error: missing', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrors.missing.push('myModule');
          this.output.dependencies.push({
            name: 'myModule',
            files: ['server.js'],
            scripts: [],
            error: ERRORS.MISSING,
            errorIgnored: true,
          });
        });

        it('returns ignored error: missing', function() {
          this.expectOutputToMatch();
        });
      });
    });

    describe('listed as dependency', function() {
      beforeEach(function() {
        this.input.listedModules.dependencies.push('myModule');
        this.output.dependencies.push({
          name: 'myModule',
          files: ['server.js'],
          scripts: [],
        });
      });

      it('returns success', function() {
        this.expectOutputToMatch();
      });
    });

    describe('listed as devDependency', function() {
      beforeEach(function() {
        this.input.listedModules.devDependencies.push('myModule');
      });

      describe('not ignored', function() {
        beforeEach(function() {
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server.js'],
            scripts: [],
            error: ERRORS.SHOULD_BE_DEPENDENCY,
          });
        });

        it('returns error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrors.shouldBeDependency.push('myModule');
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server.js'],
            scripts: [],
            error: ERRORS.SHOULD_BE_DEPENDENCY,
            errorIgnored: true,
          });
        });

        it('returns ignored error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });
    });

    describe('listed as dependency and devDependency', function() {
      beforeEach(function() {
        this.input.listedModules.dependencies.push('myModule');
        this.input.listedModules.devDependencies.push('myModule');
        this.output.dependencies.push({
          name: 'myModule',
          files: ['server.js'],
          scripts: [],
        });
      });

      describe('not ignored', function() {
        beforeEach(function() {
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server.js'],
            scripts: [],
            error: ERRORS.SHOULD_BE_DEPENDENCY,
          });
        });

        it('returns error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrors.shouldBeDependency.push('myModule');
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server.js'],
            scripts: [],
            error: ERRORS.SHOULD_BE_DEPENDENCY,
            errorIgnored: true,
          });
        });

        it('returns ignored error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });
    });
  });

  describe('used as a devDependency', function() {
    beforeEach(function() {
      this.input.usedModules.push({
        name: 'myModule',
        files: ['server_spec.js'],
        scripts: [],
      });
    });

    describe('not listed', function() {
      describe('not ignored', function() {
        beforeEach(function() {
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server_spec.js'],
            scripts: [],
            error: ERRORS.MISSING,
          });
        });

        it('returns error: missing', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrors.missing.push('myModule');
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server_spec.js'],
            scripts: [],
            error: ERRORS.MISSING,
            errorIgnored: true,
          });
        });

        it('returns ignored error: missing', function() {
          this.expectOutputToMatch();
        });
      });
    });

    describe('listed as dependency', function() {
      beforeEach(function() {
        this.input.listedModules.dependencies.push('myModule');
      });

      describe('not ignored', function() {
        beforeEach(function() {
          this.output.dependencies.push({
            name: 'myModule',
            files: ['server_spec.js'],
            scripts: [],
            error: ERRORS.SHOULD_BE_DEV_DEPENDENCY,
          });
        });

        it('returns error: should be a devDependency', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrors.shouldBeDevDependency.push('myModule');
          this.output.dependencies.push({
            name: 'myModule',
            files: ['server_spec.js'],
            scripts: [],
            error: ERRORS.SHOULD_BE_DEV_DEPENDENCY,
            errorIgnored: true,
          });
        });

        it('returns ignored error: should be a devDependency', function() {
          this.expectOutputToMatch();
        });
      });
    });

    describe('listed as devDependency', function() {
      beforeEach(function() {
        this.input.listedModules.devDependencies.push('myModule');
        const dependencyLinter = new DependencyLinter(this.options);
        this.result = dependencyLinter.lint(this.input);
      });

      it('returns success', function() {
        this.output.devDependencies.push({
          name: 'myModule',
          files: ['server_spec.js'],
          scripts: [],
        });
        this.expectOutputToMatch();
      });
    });

    describe('listed as dependency and devDependency', function() {
      beforeEach(function() {
        this.input.listedModules.dependencies.push('myModule');
        this.input.listedModules.devDependencies.push('myModule');
        this.output.devDependencies.push({
          name: 'myModule',
          files: ['server_spec.js'],
          scripts: [],
        });
      });

      describe('not ignored', function() {
        beforeEach(function() {
          this.output.dependencies.push({
            name: 'myModule',
            files: ['server_spec.js'],
            scripts: [],
            error: ERRORS.SHOULD_BE_DEV_DEPENDENCY,
          });
        });

        it('returns error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrors.shouldBeDevDependency.push('myModule');
          this.output.dependencies.push({
            name: 'myModule',
            files: ['server_spec.js'],
            scripts: [],
            error: ERRORS.SHOULD_BE_DEV_DEPENDENCY,
            errorIgnored: true,
          });
        });

        it('returns ignored error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });
    });
  });

  describe('used as a dependency and a devDependency', function() {
    beforeEach(function() {
      this.input.usedModules.push({
        name: 'myModule',
        files: ['server.js', 'server_spec.js'],
        scripts: [],
      });
    });

    describe('not listed', function() {
      describe('not ignored', function() {
        beforeEach(function() {
          this.output.dependencies.push({
            name: 'myModule',
            files: ['server.js', 'server_spec.js'],
            scripts: [],
            error: ERRORS.MISSING,
          });
        });

        it('returns error: missing', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrors.missing.push('myModule');
          this.output.dependencies.push({
            name: 'myModule',
            files: ['server.js', 'server_spec.js'],
            scripts: [],
            error: ERRORS.MISSING,
            errorIgnored: true,
          });
        });

        it('returns ignored error: missing', function() {
          this.expectOutputToMatch();
        });
      });
    });

    describe('listed as dependency', function() {
      beforeEach(function() {
        this.input.listedModules.dependencies.push('myModule');
        this.output.dependencies.push({
          name: 'myModule',
          files: ['server.js', 'server_spec.js'],
          scripts: [],
        });
      });

      it('returns success', function() {
        this.expectOutputToMatch();
      });
    });

    describe('listed as devDependency', function() {
      beforeEach(function() {
        this.input.listedModules.devDependencies.push('myModule');
      });

      describe('not ignored', function() {
        beforeEach(function() {
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server.js', 'server_spec.js'],
            scripts: [],
            error: ERRORS.SHOULD_BE_DEPENDENCY,
          });
        });

        it('returns error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrors.shouldBeDependency.push('myModule');
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server.js', 'server_spec.js'],
            scripts: [],
            error: ERRORS.SHOULD_BE_DEPENDENCY,
            errorIgnored: true,
          });
        });

        it('returns ignored error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });
    });

    describe('listed as dependency and devDependency', function() {
      beforeEach(function() {
        this.input.listedModules.dependencies.push('myModule');
        this.input.listedModules.devDependencies.push('myModule');
        this.output.dependencies.push({
          name: 'myModule',
          files: ['server.js', 'server_spec.js'],
          scripts: [],
        });
      });

      describe('not ignored', function() {
        beforeEach(function() {
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server.js', 'server_spec.js'],
            scripts: [],
            error: ERRORS.SHOULD_BE_DEPENDENCY,
          });
        });

        it('returns error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrors.shouldBeDependency.push('myModule');
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server.js', 'server_spec.js'],
            scripts: [],
            error: ERRORS.SHOULD_BE_DEPENDENCY,
            errorIgnored: true,
          });
        });

        it('returns ignored error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });
    });
  });

  describe('dependency-lint', () =>
    describe('not used, listed as devDependency', function() {
      beforeEach(function() {
        this.input.listedModules.devDependencies.push('dependency-lint');
        this.output.devDependencies.push({
          name: 'dependency-lint',
          files: [],
          scripts: [],
        });
      });

      it('returns success', function() {
        this.expectOutputToMatch();
      });
    }));
});
