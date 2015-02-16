DependencyLinter = require './dependency_linter'


describe 'DependencyLinter', ->
  beforeEach ->
    @dependencyLinter = new DependencyLinter {allowUnused: ['b']}
    @input =
      dependencies: {used: [], listed: []}
      devDependencies: {used: [], listed: []}
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
          @input.dependencies.listed.push 'a'
          @result = @dependencyLinter.lint @input

        it 'returned with error: unused', ->
          @output.dependencies.push {name: 'a', error: 'unused'}
          expect(@result).to.eql @output

      describe 'on allowed unused list', ->
        beforeEach ->
          @input.dependencies.listed.push 'b'
          @result = @dependencyLinter.lint @input

        it 'returned with warning: unused - allowed', ->
          @output.dependencies.push {name: 'b', warning: 'unused - allowed'}
          expect(@result).to.eql @output

    describe 'listed as devDependency', ->
      describe 'not on allowed unused list', ->
        beforeEach ->
          @input.devDependencies.listed.push 'a'
          @result = @dependencyLinter.lint @input

        it 'returned with error: unused error', ->
          @output.devDependencies.push {name: 'a', error: 'unused'}
          expect(@result).to.eql @output

      describe 'on allowed unused list', ->
        beforeEach ->
          @input.devDependencies.listed.push 'b'
          @result = @dependencyLinter.lint @input

        it 'returned with warning: unused - allowed', ->
          @output.devDependencies.push {name: 'b', warning: 'unused - allowed'}
          expect(@result).to.eql @output


  describe 'used as a dependency', ->
    beforeEach ->
      @input.dependencies.used.push 'a'

    describe 'not listed', ->
      beforeEach ->
        @result = @dependencyLinter.lint @input

      it 'returned with error: missing', ->
        @output.dependencies.push {name: 'a', error: 'missing'}
        expect(@result).to.eql @output

    describe 'listed as dependency', ->
      beforeEach ->
        @input.dependencies.listed.push 'a'
        @result = @dependencyLinter.lint @input

      it 'returned with no error or warning', ->
        @output.dependencies.push {name: 'a'}
        expect(@result).to.eql @output

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.devDependencies.listed.push 'a'
        @result = @dependencyLinter.lint @input

      it 'returned with error: should be a dependency', ->
        @output.devDependencies.push {name: 'a', error: 'should be dependency'}
        expect(@result).to.eql @output


  describe 'used as a devDependency', ->
    beforeEach ->
      @input.devDependencies.used.push 'a'

    describe 'not listed', ->
      beforeEach ->
        @result = @dependencyLinter.lint @input

      it 'returned with error: missing', ->
        @output.devDependencies.push {name: 'a', error: 'missing'}
        expect(@result).to.eql @output

    describe 'listed as dependency', ->
      beforeEach ->
        @input.dependencies.listed.push 'a'
        @result = @dependencyLinter.lint @input

      it 'returned with error: should be a devDependency', ->
        @output.dependencies.push {name: 'a', error: 'should be devDependency'}
        expect(@result).to.eql @output

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.devDependencies.listed.push 'a'
        @result = @dependencyLinter.lint @input

      it 'returned with no error or warning', ->
        @output.devDependencies.push {name: 'a'}
        expect(@result).to.eql @output


  describe 'used as a dependency and a devDependency', ->
    beforeEach ->
      @input.dependencies.used.push 'a'
      @input.devDependencies.used.push 'a'

    describe 'not listed', ->
      beforeEach ->
        @result = @dependencyLinter.lint @input

      it 'returned with error: missing', ->
        @output.dependencies.push {name: 'a', error: 'missing'}
        expect(@result).to.eql @output

    describe 'listed as dependency', ->
      beforeEach ->
        @input.dependencies.listed.push 'a'
        @result = @dependencyLinter.lint @input

      it 'returned with no error or warning', ->
        @output.dependencies.push {name: 'a'}
        expect(@result).to.eql @output

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.devDependencies.listed.push 'a'
        @result = @dependencyLinter.lint @input

      it 'returned with error: should be a dependency', ->
        @output.devDependencies.push {name: 'a', error: 'should be dependency'}
        expect(@result).to.eql @output
