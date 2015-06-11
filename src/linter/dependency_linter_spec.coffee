DependencyLinter = require './dependency_linter'


describe 'DependencyLinter', ->
  beforeEach ->
    @dependencyLinter = new DependencyLinter
      allowUnused: ['b']
      devFilePatterns: ['**/*_spec.coffee']
      devScripts: ['test']

    @input =
      listedModules: {dependencies: [], devDependencies: []}
      usedModules: []

    @output =
      dependencies: []
      devDependencies: []


  describe 'not used', ->
    describe 'not listed', ->
      beforeEach ->
        @result = @dependencyLinter.lint @input

      it 'returns nothing', ->
        expect(@result).to.eql @output

    describe 'listed as dependency', ->
      describe 'not on allow unused list', ->
        beforeEach ->
          @input.listedModules.dependencies.push 'a'
          @result = @dependencyLinter.lint @input

        it 'returned with error: unused', ->
          @output.dependencies.push {name: 'a', error: 'unused'}
          expect(@result).to.eql @output

      describe 'on allowed unused list', ->
        beforeEach ->
          @input.listedModules.dependencies.push 'b'
          @result = @dependencyLinter.lint @input

        it 'returned with warning: unused - allowed', ->
          @output.dependencies.push {name: 'b', warning: 'unused - allowed'}
          expect(@result).to.eql @output

    describe 'listed as devDependency', ->
      describe 'not on allowed unused list', ->
        beforeEach ->
          @input.listedModules.devDependencies.push 'a'
          @result = @dependencyLinter.lint @input

        it 'returned with error: unused error', ->
          @output.devDependencies.push {name: 'a', error: 'unused'}
          expect(@result).to.eql @output

      describe 'on allowed unused list', ->
        beforeEach ->
          @input.listedModules.devDependencies.push 'b'
          @result = @dependencyLinter.lint @input

        it 'returned with warning: unused - allowed', ->
          @output.devDependencies.push {name: 'b', warning: 'unused - allowed'}
          expect(@result).to.eql @output


  describe 'used as a dependency', ->
    beforeEach ->
      @input.usedModules.push {name: 'a', files: ['a.coffee'], scripts: []}

    describe 'not listed', ->
      beforeEach ->
        @result = @dependencyLinter.lint @input

      it 'returned with error: missing', ->
        @output.dependencies.push {name: 'a', files: ['a.coffee'], scripts: [], error: 'missing'}
        expect(@result).to.eql @output

    describe 'listed as dependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'a'
        @result = @dependencyLinter.lint @input

      it 'returned with no error or warning', ->
        @output.dependencies.push {name: 'a', files: ['a.coffee'], scripts: []}
        expect(@result).to.eql @output

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.listedModules.devDependencies.push 'a'
        @result = @dependencyLinter.lint @input

      it 'returned with error: should be a dependency', ->
        @output.devDependencies.push(
          name: 'a', files: ['a.coffee'], scripts: [], error: 'should be dependency')
        expect(@result).to.eql @output


  describe 'used as a devDependency', ->
    beforeEach ->
      @input.usedModules.push {name: 'a', files: ['a_spec.coffee'], scripts: []}

    describe 'not listed', ->
      beforeEach ->
        @result = @dependencyLinter.lint @input

      it 'returned with error: missing', ->
        @output.devDependencies.push(
          name: 'a', files: ['a_spec.coffee'], scripts: [], error: 'missing')
        expect(@result).to.eql @output

    describe 'listed as dependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'a'
        @result = @dependencyLinter.lint @input

      it 'returned with error: should be a devDependency', ->
        @output.dependencies.push(
          name: 'a', files: ['a_spec.coffee'], scripts: [], error: 'should be devDependency')
        expect(@result).to.eql @output

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.listedModules.devDependencies.push 'a'
        @result = @dependencyLinter.lint @input

      it 'returned with no error or warning', ->
        @output.devDependencies.push {name: 'a', files: ['a_spec.coffee'], scripts: []}
        expect(@result).to.eql @output


  describe 'used as a dependency and a devDependency', ->
    beforeEach ->
      @input.usedModules.push {name: 'a', files: ['a.coffee', 'a_spec.coffee'], scripts: []}

    describe 'not listed', ->
      beforeEach ->
        @result = @dependencyLinter.lint @input

      it 'returned with error: missing', ->
        @output.dependencies.push(
          name: 'a', files: ['a.coffee', 'a_spec.coffee'], scripts: [],  error: 'missing')
        expect(@result).to.eql @output

    describe 'listed as dependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'a'
        @result = @dependencyLinter.lint @input

      it 'returned with no error or warning', ->
        @output.dependencies.push {name: 'a', files: ['a.coffee', 'a_spec.coffee'], scripts: []}
        expect(@result).to.eql @output

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.listedModules.devDependencies.push 'a'
        @result = @dependencyLinter.lint @input

      it 'returned with error: should be a dependency', ->
        @output.devDependencies.push(
          name: 'a'
          files: ['a.coffee', 'a_spec.coffee']
          scripts: []
          error: 'should be dependency')
        expect(@result).to.eql @output
