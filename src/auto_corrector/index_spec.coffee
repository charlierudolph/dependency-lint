AutoCorrector = require './'
ERRORS = require '../errors'


describe 'AutoCorrector', ->
  beforeEach ->
    @autoCorrector = new AutoCorrector()

  describe 'correct', ->
    beforeEach ->
      @results =
        dependencies: []
        devDependencies: []
      @packageJson =
        dependencies: {a: '0.0.1'}
        devDependencies: {b: '0.0.1'}
        name: 'test'

    describe 'no errors', ->
      beforeEach ->
        @results.dependencies.push name: 'a'
        @results.devDependencies.push name: 'b'
        {@fixes, @updatedPackageJson} = @autoCorrector.correct {@packageJson, @results}

      it 'returns no fixes', ->
        expect(@fixes).to.eql
          dependencies: []
          devDependencies: []

      it 'returns an unchanged package.json', ->
        expect(@updatedPackageJson).to.eql
          dependencies: {a: '0.0.1'}
          devDependencies: {b: '0.0.1'}
          name: 'test'

    describe 'dependency unused', ->
      beforeEach ->
        @results.dependencies.push name: 'a', error: ERRORS.UNUSED
        @results.devDependencies.push name: 'b'
        {@fixes, @updatedPackageJson} = @autoCorrector.correct {@packageJson, @results}

      it 'returns the modules that were fixed', ->
        expect(@fixes).to.eql
          dependencies: ['a']
          devDependencies: []

      it 'returns an updated package.json', ->
        expect(@updatedPackageJson).to.eql
          dependencies: {}
          devDependencies: {b: '0.0.1'}
          name: 'test'

    describe 'devDependency unused', ->
      beforeEach ->
        @results.dependencies.push name: 'a'
        @results.devDependencies.push name: 'b', error: ERRORS.UNUSED
        {@fixes, @updatedPackageJson} = @autoCorrector.correct {@packageJson, @results}

      it 'returns the modules that were fixed', ->
        expect(@fixes).to.eql
          dependencies: []
          devDependencies: ['b']

      it 'returns an updated package.json', ->
        expect(@updatedPackageJson).to.eql
          dependencies: {a: '0.0.1'}
          devDependencies: {}
          name: 'test'

    describe 'dependency should be devDependency', ->
      beforeEach ->
        @results.dependencies.push name: 'a', error: ERRORS.SHOULD_BE_DEV_DEPENDENCY
        @results.devDependencies.push name: 'b'
        {@fixes, @updatedPackageJson} = @autoCorrector.correct {@packageJson, @results}

      it 'returns the modules that were fixed', ->
        expect(@fixes).to.eql
          dependencies: ['a']
          devDependencies: []

      it 'returns an updated package.json', ->
        expect(@updatedPackageJson).to.eql
          dependencies: {}
          devDependencies: {a: '0.0.1', b: '0.0.1'}
          name: 'test'

    describe 'devDependency should be dependency', ->
      beforeEach ->
        @results.dependencies.push name: 'a'
        @results.devDependencies.push name: 'b', error: ERRORS.SHOULD_BE_DEPENDENCY
        {@fixes, @updatedPackageJson} = @autoCorrector.correct {@packageJson, @results}

      it 'returns the modules that were fixed', ->
        expect(@fixes).to.eql
          dependencies: []
          devDependencies: ['b']

      it 'returns an updated package.json', ->
        expect(@updatedPackageJson).to.eql
          dependencies: {a: '0.0.1', b: '0.0.1'}
          devDependencies: {}
          name: 'test'
