DependencyLinter = require './dependency_linter'


describe 'DependencyLinter', ->
  beforeEach ->
    @dependencyLinter = new DependencyLinter
      allowUnused: ['specialModule']
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
          @input.listedModules.dependencies.push 'myModule'
          @result = @dependencyLinter.lint @input

        it 'returned with error: unused', ->
          @output.dependencies.push {name: 'myModule', error: 'unused'}
          expect(@result).to.eql @output

      describe 'on allowed unused list', ->
        beforeEach ->
          @input.listedModules.dependencies.push 'specialModule'
          @result = @dependencyLinter.lint @input

        it 'returned with warning: unused - allowed', ->
          @output.dependencies.push {name: 'specialModule', warning: 'unused - allowed'}
          expect(@result).to.eql @output

    describe 'listed as devDependency', ->
      describe 'not on allowed unused list', ->
        beforeEach ->
          @input.listedModules.devDependencies.push 'myModule'
          @result = @dependencyLinter.lint @input

        it 'returned with error: unused error', ->
          @output.devDependencies.push {name: 'myModule', error: 'unused'}
          expect(@result).to.eql @output

      describe 'on allowed unused list', ->
        beforeEach ->
          @input.listedModules.devDependencies.push 'specialModule'
          @result = @dependencyLinter.lint @input

        it 'returned with warning: unused - allowed', ->
          @output.devDependencies.push {name: 'specialModule', warning: 'unused - allowed'}
          expect(@result).to.eql @output


  describe 'used as a dependency', ->
    beforeEach ->
      @input.usedModules.push {name: 'myModule', files: ['server.coffee'], scripts: []}

    describe 'not listed', ->
      beforeEach ->
        @result = @dependencyLinter.lint @input

      it 'returned with error: missing', ->
        @output.dependencies.push
          name: 'myModule'
          files: ['server.coffee']
          scripts: []
          error: 'missing'
        expect(@result).to.eql @output

    describe 'listed as dependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'
        @result = @dependencyLinter.lint @input

      it 'returned with no error or warning', ->
        @output.dependencies.push {name: 'myModule', files: ['server.coffee'], scripts: []}
        expect(@result).to.eql @output

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.listedModules.devDependencies.push 'myModule'
        @result = @dependencyLinter.lint @input

      it 'returned with error: should be a dependency', ->
        @output.devDependencies.push
          name: 'myModule'
          files: ['server.coffee']
          scripts: []
          error: 'should be dependency'
        expect(@result).to.eql @output

    describe 'listed as dependency and devDependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'
        @input.listedModules.devDependencies.push 'myModule'
        @result = @dependencyLinter.lint @input

      it 'returned with error: should be a dependency', ->
        @output.dependencies.push {name: 'myModule', files: ['server.coffee'], scripts: []}
        @output.devDependencies.push
          name: 'myModule'
          files: ['server.coffee']
          scripts: []
          error: 'should be dependency'
        expect(@result).to.eql @output


  describe 'used as a devDependency', ->
    beforeEach ->
      @input.usedModules.push {name: 'myModule', files: ['server_spec.coffee'], scripts: []}

    describe 'not listed', ->
      beforeEach ->
        @result = @dependencyLinter.lint @input

      it 'returned with error: missing', ->
        @output.devDependencies.push
          name: 'myModule'
          files: ['server_spec.coffee']
          scripts: []
          error: 'missing'
        expect(@result).to.eql @output

    describe 'listed as dependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'
        @result = @dependencyLinter.lint @input

      it 'returned with error: should be a devDependency', ->
        @output.dependencies.push
          name: 'myModule'
          files: ['server_spec.coffee']
          scripts: []
          error: 'should be devDependency'
        expect(@result).to.eql @output

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.listedModules.devDependencies.push 'myModule'
        @result = @dependencyLinter.lint @input

      it 'returned with no error or warning', ->
        @output.devDependencies.push {name: 'myModule', files: ['server_spec.coffee'], scripts: []}
        expect(@result).to.eql @output

    describe 'listed as dependency and devDependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'
        @input.listedModules.devDependencies.push 'myModule'
        @result = @dependencyLinter.lint @input

      it 'returned with error: should be a dependency', ->
        @output.dependencies.push
          name: 'myModule'
          files: ['server_spec.coffee']
          scripts: []
          error: 'should be devDependency'
        @output.devDependencies.push {name: 'myModule', files: ['server_spec.coffee'], scripts: []}
        expect(@result).to.eql @output


  describe 'used as a dependency and a devDependency', ->
    beforeEach ->
      @input.usedModules.push
        name: 'myModule'
        files: ['server.coffee', 'server_spec.coffee']
        scripts: []

    describe 'not listed', ->
      beforeEach ->
        @result = @dependencyLinter.lint @input

      it 'returned with error: missing', ->
        @output.dependencies.push
          name: 'myModule'
          files: ['server.coffee', 'server_spec.coffee']
          scripts: []
          error: 'missing'
        expect(@result).to.eql @output

    describe 'listed as dependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'
        @result = @dependencyLinter.lint @input

      it 'returned with no error or warning', ->
        @output.dependencies.push
          name: 'myModule'
          files: ['server.coffee', 'server_spec.coffee']
          scripts: []
        expect(@result).to.eql @output

    describe 'listed as devDependency', ->
      beforeEach ->
        @input.listedModules.devDependencies.push 'myModule'
        @result = @dependencyLinter.lint @input

      it 'returned with error: should be a dependency', ->
        @output.devDependencies.push
          name: 'myModule'
          files: ['server.coffee', 'server_spec.coffee']
          scripts: []
          error: 'should be dependency'
        expect(@result).to.eql @output

    describe 'listed as dependency and devDependency', ->
      beforeEach ->
        @input.listedModules.dependencies.push 'myModule'
        @input.listedModules.devDependencies.push 'myModule'
        @result = @dependencyLinter.lint @input

      it 'returned with error: should be a dependency', ->
        @output.dependencies.push
          name: 'myModule'
          files: ['server.coffee', 'server_spec.coffee']
          scripts: []
        @output.devDependencies.push
          name: 'myModule'
          files: ['server.coffee', 'server_spec.coffee']
          scripts: []
          error: 'should be dependency'
        expect(@result).to.eql @output
