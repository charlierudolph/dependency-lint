AutoCorrector = require './'
ERRORS = require '../errors'

examples = [
  description: 'no errors'
  inputResults:
    dependencies: [{name: 'a'}]
    devDependencies: [{name: 'b'}]
  output:
    fixes:
      dependencies: []
      devDependencies: []
    updatedPackageJson:
      dependencies: {a: '0.0.1'}
      devDependencies: {b: '0.0.1'}
      name: 'test'
,
  description: 'dependency unused'
  inputResults:
    dependencies: [{name: 'a', error: ERRORS.UNUSED}]
    devDependencies: [{name: 'b'}]
  output:
    fixes:
      dependencies: ['a']
      devDependencies: []
    updatedPackageJson:
      dependencies: {}
      devDependencies: {b: '0.0.1'}
      name: 'test'
,
  description: 'dependency unused - ignored'
  inputResults:
    dependencies: [{name: 'a', error: ERRORS.UNUSED, errorIgnored: true}]
    devDependencies: [{name: 'b'}]
  output:
    fixes:
      dependencies: []
      devDependencies: []
    updatedPackageJson:
      dependencies: {a: '0.0.1'}
      devDependencies: {b: '0.0.1'}
      name: 'test'
,
  description: 'devDependency unused'
  inputResults:
    dependencies: [{name: 'a'}]
    devDependencies: [{name: 'b', error: ERRORS.UNUSED}]
  output:
    fixes:
      dependencies: []
      devDependencies: ['b']
    updatedPackageJson:
      dependencies: {a: '0.0.1'}
      devDependencies: {}
      name: 'test'
,
  description: 'dependency should be devDependency'
  inputResults:
    dependencies: [{name: 'a', error: ERRORS.SHOULD_BE_DEV_DEPENDENCY}]
    devDependencies: [{name: 'b'}]
  output:
    fixes:
      dependencies: ['a']
      devDependencies: []
    updatedPackageJson:
      dependencies: {}
      devDependencies: {a: '0.0.1', b: '0.0.1'}
      name: 'test'
,
  description: 'devDependency should be dependency'
  inputResults:
    dependencies: [{name: 'a'}]
    devDependencies: [{name: 'b', error: ERRORS.SHOULD_BE_DEPENDENCY}]
  output:
    fixes:
      dependencies: []
      devDependencies: ['b']
    updatedPackageJson:
      dependencies: {a: '0.0.1', b: '0.0.1'}
      devDependencies: {}
      name: 'test'
]

describe 'AutoCorrector', ->
  beforeEach ->
    @autoCorrector = new AutoCorrector()

  describe 'correct', ->
    beforeEach ->
      @results =
        dependencies: ['a']
        devDependencies: []
      @packageJson =
        dependencies: {a: '0.0.1'}
        devDependencies: {b: '0.0.1'}
        name: 'test'

    examples.forEach ({inputResults, description, output}) ->
      it description, ->
        input = {@packageJson, results: inputResults}
        result = @autoCorrector.correct input
        expect(result).to.eql output
