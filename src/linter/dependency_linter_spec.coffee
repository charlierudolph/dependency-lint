_ = require 'lodash'
DependencyLinter = require './dependency_linter'
ERRORS = require '../errors'

describe 'DependencyLinter', ->
  beforeEach ->
    @options =
      executedModules:
        npmScripts:
          dev: ['test']
        shellScripts:
          dev: []
      ignoreErrors:
        missing: []
        shouldBeDependency: []
        shouldBeDevDependency: []
        unused: []
      requiredModules:
        files:
          dev: ['**/*_spec.coffee']

    @input =
      listedModules: {dependencies: [], devDependencies: []}
      usedModules: []

    @output =
      dependencies: []
      devDependencies: []

    @expectOutputToMatch = ->
      dependencyLinter = new DependencyLinter @options
      @result = dependencyLinter.lint @input
      expect(@result).to.eql @output


  describe 'not used', ->
    describe 'not listed', ->
      beforeEach ->
        dependencyLinter = new DependencyLinter @options
        @result = dependencyLinter.lint @input

      it 'returns nothing', ->
        @expectOutputToMatch()

    describe 'listed as dependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'

      describe 'not ignored', ->
        beforeEach ->
          @output.dependencies.push {name: 'myModule', error: ERRORS.UNUSED}

        it 'returns error: unused', ->
          @expectOutputToMatch()

      describe 'ignored', ->
        beforeEach ->
          @options.ignoreErrors.unused.push 'myModule'
          @output.dependencies.push {name: 'myModule', error: ERRORS.UNUSED, errorIgnored: true}

        it 'returns ignored error: unused', ->
          @expectOutputToMatch()

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.listedModules.devDependencies.push 'myModule'

      describe 'not ignored', ->
        beforeEach ->
          @output.devDependencies.push {name: 'myModule', error: ERRORS.UNUSED}

        it 'returns error: unused', ->
          @expectOutputToMatch()

      describe 'on allowed unused list', ->
        beforeEach ->
          @options.ignoreErrors.unused.push 'myModule'
          @output.devDependencies.push {name: 'myModule', error: ERRORS.UNUSED, errorIgnored: true}

        it 'returns ignored error: unused', ->
          @expectOutputToMatch()


  describe 'used as a dependency', ->
    beforeEach ->
      @input.usedModules.push {name: 'myModule', files: ['server.coffee'], scripts: []}

    describe 'not listed', ->
      describe 'not ignored', ->
        beforeEach ->
          @output.dependencies.push
            name: 'myModule'
            files: ['server.coffee']
            scripts: []
            error: ERRORS.MISSING

        it 'returns error: missing', ->
          @expectOutputToMatch()

      describe 'ignored', ->
        beforeEach ->
          @options.ignoreErrors.missing.push 'myModule'
          @output.dependencies.push
            name: 'myModule'
            files: ['server.coffee']
            scripts: []
            error: ERRORS.MISSING
            errorIgnored: true

        it 'returns ignored error: missing', ->
          @expectOutputToMatch()

    describe 'listed as dependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'
        @output.dependencies.push {name: 'myModule', files: ['server.coffee'], scripts: []}

      it 'returns success', ->
        @expectOutputToMatch()

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.listedModules.devDependencies.push 'myModule'

      describe 'not ignored', ->
        beforeEach ->
          @output.devDependencies.push
            name: 'myModule'
            files: ['server.coffee']
            scripts: []
            error: ERRORS.SHOULD_BE_DEPENDENCY

        it 'returns error: should be a dependency', ->
          @expectOutputToMatch()

      describe 'ignored', ->
        beforeEach ->
          @options.ignoreErrors.shouldBeDependency.push 'myModule'
          @output.devDependencies.push
            name: 'myModule'
            files: ['server.coffee']
            scripts: []
            error: ERRORS.SHOULD_BE_DEPENDENCY
            errorIgnored: true

        it 'returns ignored error: should be a dependency', ->
          @expectOutputToMatch()

    describe 'listed as dependency and devDependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'
        @input.listedModules.devDependencies.push 'myModule'
        @output.dependencies.push {name: 'myModule', files: ['server.coffee'], scripts: []}

      describe 'not ignored', ->
        beforeEach ->
          @output.devDependencies.push
            name: 'myModule'
            files: ['server.coffee']
            scripts: []
            error: ERRORS.SHOULD_BE_DEPENDENCY

        it 'returns error: should be a dependency', ->
          @expectOutputToMatch()

      describe 'ignored', ->
        beforeEach ->
          @options.ignoreErrors.shouldBeDependency.push 'myModule'
          @output.devDependencies.push
            name: 'myModule'
            files: ['server.coffee']
            scripts: []
            error: ERRORS.SHOULD_BE_DEPENDENCY
            errorIgnored: true

        it 'returns ignored error: should be a dependency', ->
          @expectOutputToMatch()


  describe 'used as a devDependency', ->
    beforeEach ->
      @input.usedModules.push {name: 'myModule', files: ['server_spec.coffee'], scripts: []}

    describe 'not listed', ->
      describe 'not ignored', ->
        beforeEach ->
          @output.devDependencies.push
            name: 'myModule'
            files: ['server_spec.coffee']
            scripts: []
            error: ERRORS.MISSING

        it 'returns error: missing', ->
          @expectOutputToMatch()

      describe 'ignored', ->
        beforeEach ->
          @options.ignoreErrors.missing.push 'myModule'
          @output.devDependencies.push
            name: 'myModule'
            files: ['server_spec.coffee']
            scripts: []
            error: ERRORS.MISSING
            errorIgnored: true

        it 'returns ignored error: missing', ->
          @expectOutputToMatch()

    describe 'listed as dependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'

      describe 'not ignored', ->
        beforeEach ->
          @output.dependencies.push
            name: 'myModule'
            files: ['server_spec.coffee']
            scripts: []
            error: ERRORS.SHOULD_BE_DEV_DEPENDENCY

        it 'returns error: should be a devDependency', ->
          @expectOutputToMatch()

      describe 'ignored', ->
        beforeEach ->
          @options.ignoreErrors.shouldBeDevDependency.push 'myModule'
          @output.dependencies.push
            name: 'myModule'
            files: ['server_spec.coffee']
            scripts: []
            error: ERRORS.SHOULD_BE_DEV_DEPENDENCY
            errorIgnored: true

        it 'returns ignored error: should be a devDependency', ->
          @expectOutputToMatch()

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.listedModules.devDependencies.push 'myModule'
        dependencyLinter = new DependencyLinter @options
        @result = dependencyLinter.lint @input

      it 'returns success', ->
        @output.devDependencies.push {name: 'myModule', files: ['server_spec.coffee'], scripts: []}
        @expectOutputToMatch()

    describe 'listed as dependency and devDependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'
        @input.listedModules.devDependencies.push 'myModule'
        @output.devDependencies.push {name: 'myModule', files: ['server_spec.coffee'], scripts: []}

      describe 'not ignored', ->
        beforeEach ->
          @output.dependencies.push
            name: 'myModule'
            files: ['server_spec.coffee']
            scripts: []
            error: ERRORS.SHOULD_BE_DEV_DEPENDENCY

        it 'returns error: should be a dependency', ->
          @expectOutputToMatch()

      describe 'ignored', ->
        beforeEach ->
          @options.ignoreErrors.shouldBeDevDependency.push 'myModule'
          @output.dependencies.push
            name: 'myModule'
            files: ['server_spec.coffee']
            scripts: []
            error: ERRORS.SHOULD_BE_DEV_DEPENDENCY
            errorIgnored: true

        it 'returns ignored error: should be a dependency', ->
          @expectOutputToMatch()


  describe 'used as a dependency and a devDependency', ->
    beforeEach ->
      @input.usedModules.push
        name: 'myModule'
        files: ['server.coffee', 'server_spec.coffee']
        scripts: []

    describe 'not listed', ->
      describe 'not ignored', ->
        beforeEach ->
          @output.dependencies.push
            name: 'myModule'
            files: ['server.coffee', 'server_spec.coffee']
            scripts: []
            error: ERRORS.MISSING

        it 'returns error: missing', ->
          @expectOutputToMatch()

      describe 'ignored', ->
        beforeEach ->
          @options.ignoreErrors.missing.push 'myModule'
          @output.dependencies.push
            name: 'myModule'
            files: ['server.coffee', 'server_spec.coffee']
            scripts: []
            error: ERRORS.MISSING
            errorIgnored: true

        it 'returns ignored error: missing', ->
          @expectOutputToMatch()

    describe 'listed as dependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'
        @output.dependencies.push
          name: 'myModule'
          files: ['server.coffee', 'server_spec.coffee']
          scripts: []

      it 'returns success', ->
        @expectOutputToMatch()

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.listedModules.devDependencies.push 'myModule'

      describe 'not ignored', ->
        beforeEach ->
          @output.devDependencies.push
            name: 'myModule'
            files: ['server.coffee', 'server_spec.coffee']
            scripts: []
            error: ERRORS.SHOULD_BE_DEPENDENCY

        it 'returns error: should be a dependency', ->
          @expectOutputToMatch()

      describe 'ignored', ->
        beforeEach ->
          @options.ignoreErrors.shouldBeDependency.push 'myModule'
          @output.devDependencies.push
            name: 'myModule'
            files: ['server.coffee', 'server_spec.coffee']
            scripts: []
            error: ERRORS.SHOULD_BE_DEPENDENCY
            errorIgnored: true

        it 'returns ignored error: should be a dependency', ->
          @expectOutputToMatch()


    describe 'listed as dependency and devDependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'
        @input.listedModules.devDependencies.push 'myModule'
        @output.dependencies.push
          name: 'myModule'
          files: ['server.coffee', 'server_spec.coffee']
          scripts: []

      describe 'not ignored', ->
        beforeEach ->
          @output.devDependencies.push
            name: 'myModule'
            files: ['server.coffee', 'server_spec.coffee']
            scripts: []
            error: ERRORS.SHOULD_BE_DEPENDENCY

        it 'returns error: should be a dependency', ->
          @expectOutputToMatch()

      describe 'ignored', ->
        beforeEach ->
          @options.ignoreErrors.shouldBeDependency.push 'myModule'
          @output.devDependencies.push
            name: 'myModule'
            files: ['server.coffee', 'server_spec.coffee']
            scripts: []
            error: ERRORS.SHOULD_BE_DEPENDENCY
            errorIgnored: true

        it 'returns ignored error: should be a dependency', ->
          @expectOutputToMatch()

  describe 'dependency-lint', ->
    describe 'not used, listed as devDependency', ->
      beforeEach ->
        @input.listedModules.devDependencies.push 'dependency-lint'
        @output.devDependencies.push {name: 'dependency-lint'}

      it 'returns success', ->
        @expectOutputToMatch()
