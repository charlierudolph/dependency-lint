import DependencyLinter, { DependencyType, LintInput } from './dependency_linter';
import { ErrorType } from '../errors';
import { beforeEach, describe, it } from 'mocha';
import { expect } from 'chai';
import { DependencyLintConfig } from '../types';

describe('DependencyLinter', function() {
  let options: DependencyLintConfig;

  beforeEach(function() {
    options = {
      executedModules: {
        npmScripts: {
          dev: ['test'],
        },
        shellScripts: {
          dev: [],
          ignore: [],
          root: ''
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
          dev: ['**/*_spec.js'],
          ignore: [],
          root: ''
        },
        stripLoaders: false,
        transpilers: [],
      },
    };
  });

  describe('not used', function() {
    describe('not listed', function() {
      it('returns nothing', function() {
        // Arrange
        const dependencyLinter = new DependencyLinter(options);
        const input: LintInput = {
          listedModules: [],
          usedModules: []
        }

        // Act
        const result = dependencyLinter.lint(input)

        // Assert
        expect(result).to.eql([])
      });
    });

    describe('listed as dependency', function() {
      describe('not ignored', function() {
        it('returns error: unused', function() {
          // Arrange
          const dependencyLinter = new DependencyLinter(options);
          const input: LintInput = {
            listedModules: [{ name: 'myModule', dependencyType: DependencyType.DEPENDENCY }],
            usedModules: []
          }

          // Act
          const result = dependencyLinter.lint(input)

          // Assert
          expect(result).to.eql([{
            name: 'myModule',
            listedDependencyType: DependencyType.DEPENDENCY,
            fiiles: [],
            scripts: [],
            error: ErrorType.UNUSED,
            errorIgnored: false
          }])
        });
      });

      describe('ignored', function() {
        it('returns ignored error: unused', function() {
          // Arrange
          options.ignoreErrors.unused.push('myModule');
          const dependencyLinter = new DependencyLinter(options);
          const input: LintInput = {
            listedModules: [{ name: 'myModule', dependencyType: DependencyType.DEPENDENCY }],
            usedModules: []
          }

          // Act
          const result = dependencyLinter.lint(input)

          // Assert
          expect(result).to.eql([{
            name: 'myModule',
            listedDependencyType: DependencyType.DEPENDENCY,
            fiiles: [],
            scripts: [],
            error: ErrorType.UNUSED,
            errorIgnored: true
          }])
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
            error: ErrorType.UNUSED,
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
          this.options.ignoreErrorType.unused.push('myModule');
          this.output.devDependencies.push({
            name: 'myModule',
            error: ErrorType.UNUSED,
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
            error: ErrorType.MISSING,
          });
        });

        it('returns error: missing', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrorType.missing.push('myModule');
          this.output.dependencies.push({
            name: 'myModule',
            files: ['server.js'],
            scripts: [],
            error: ErrorType.MISSING,
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
            error: ErrorType.SHOULD_BE_DEPENDENCY,
          });
        });

        it('returns error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrorType.shouldBeDependency.push('myModule');
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server.js'],
            scripts: [],
            error: ErrorType.SHOULD_BE_DEPENDENCY,
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
            error: ErrorType.SHOULD_BE_DEPENDENCY,
          });
        });

        it('returns error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrorType.shouldBeDependency.push('myModule');
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server.js'],
            scripts: [],
            error: ErrorType.SHOULD_BE_DEPENDENCY,
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
            error: ErrorType.MISSING,
          });
        });

        it('returns error: missing', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrorType.missing.push('myModule');
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server_spec.js'],
            scripts: [],
            error: ErrorType.MISSING,
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
            error: ErrorType.SHOULD_BE_DEV_DEPENDENCY,
          });
        });

        it('returns error: should be a devDependency', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrorType.shouldBeDevDependency.push('myModule');
          this.output.dependencies.push({
            name: 'myModule',
            files: ['server_spec.js'],
            scripts: [],
            error: ErrorType.SHOULD_BE_DEV_DEPENDENCY,
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
            error: ErrorType.SHOULD_BE_DEV_DEPENDENCY,
          });
        });

        it('returns error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrorType.shouldBeDevDependency.push('myModule');
          this.output.dependencies.push({
            name: 'myModule',
            files: ['server_spec.js'],
            scripts: [],
            error: ErrorType.SHOULD_BE_DEV_DEPENDENCY,
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
            error: ErrorType.MISSING,
          });
        });

        it('returns error: missing', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrorType.missing.push('myModule');
          this.output.dependencies.push({
            name: 'myModule',
            files: ['server.js', 'server_spec.js'],
            scripts: [],
            error: ErrorType.MISSING,
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
            error: ErrorType.SHOULD_BE_DEPENDENCY,
          });
        });

        it('returns error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrorType.shouldBeDependency.push('myModule');
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server.js', 'server_spec.js'],
            scripts: [],
            error: ErrorType.SHOULD_BE_DEPENDENCY,
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
            error: ErrorType.SHOULD_BE_DEPENDENCY,
          });
        });

        it('returns error: should be a dependency', function() {
          this.expectOutputToMatch();
        });
      });

      describe('ignored', function() {
        beforeEach(function() {
          this.options.ignoreErrorType.shouldBeDependency.push('myModule');
          this.output.devDependencies.push({
            name: 'myModule',
            files: ['server.js', 'server_spec.js'],
            scripts: [],
            error: ErrorType.SHOULD_BE_DEPENDENCY,
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
