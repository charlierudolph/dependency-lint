module.exports =

  # Default options to pass to mocha (can be overriden by command line options)
  mochaOptions:
    colors: yes
    compilers: 'coffee:coffee-script/register'
    reporter: 'spec'

  # Regular expressions for files that are tests
  testFileRegex: /_spec\.coffee$/

  # Files to include before all tests
  testHelpers: [
    'spec/spec_helper.coffee'
  ]
