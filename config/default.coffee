module.exports =

  # array of strings or regular expressions to match against a module name
  # to determine if it is allowed to be unused
  allowUnused: []

  # array of path patterns to match againt a filename
  # to determine if it is used only for development
  #   (see https://github.com/isaacs/minimatch)
  devFilePatterns: [
    '{features,spec,test}/**/*'
    '**/*_{spec,test}.{coffee,js}'
  ]

  # array of strings or regular expressions to match against a script name in your `package.json`
  # to determine if it is used only for development
  devScripts: [
    'lint'
    'publish'
    'test'
  ]

  # array of path patterns to match against a filename
  # to determine if it should be ignored
  #   (see https://github.com/isaacs/minimatch)
  ignoreFilePatterns: [
    'node_modules/**/*'
  ]

  # ignore webpack loaders when evaluating requires
  # example:
  #   require('foo!bar!baz')
  # is equivalent to:
  #   require('baz')
  stripLoaders: no
