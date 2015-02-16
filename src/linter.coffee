_ = require 'lodash'
async = require 'async'
DependencyLinter = require './linter/dependency_linter'
ExecutedModuleFinder = require './linter/executed_module_finder'
path = require 'path'
RequiredModuleFinder = require './linter/required_module_finder'


class Linter

  BUILT_IN_MODULES: [
    'assert', 'buffer', 'child_process', 'cluster', 'crypto', 'dgram', 'dns', 'domain', 'events',
    'fs', 'http', 'https', 'net', 'os', 'path', 'punycode', 'querystring', 'readline', 'reply',
    'stream', 'string_decoder', 'tls', 'tty', 'url', 'util', 'vm', 'zlib'
  ]

  constructor: (@dir, {devFiles, devScripts, ignoreFiles, ignoreUnused}) ->
    @dependencyLinter = new DependencyLinter {ignoreUnused}
    @executedModuleFinder = new ExecutedModuleFinder {devScripts, @dir}
    @requiredModuleFinder = new RequiredModuleFinder {devFiles, @dir, ignoreFiles}
    @listedModules = @getListedModules()


  lint: (done) ->
    async.parallel [
      (taskDone) => @requiredModuleFinder.find taskDone
      (taskDone) => @executedModuleFinder.find taskDone
    ], (err, [requiredModules, executedModules]) =>
      if err then return done err
      done null, @dependencyLinter.lint(
        dependencies:
          used: @filterModules(requiredModules.prod, executedModules.prod)
          listed: @listedModules.prod
        devDependencies:
          used: @filterModules(requiredModules.dev, executedModules.dev)
          listed: @listedModules.dev
      )


  getListedModules: ->
    packageJson = require path.join(@dir, 'package.json')

    prod: _.keys(packageJson.dependencies)
    dev: _.keys(packageJson.devDependencies)


  filterModules: (modules...) ->
    _.chain(modules)
      .flatten()
      .filter (module) => module[0] isnt '.' and module not in @BUILT_IN_MODULES
      .map (module) -> module.replace /\/.*$/, ''
      .uniq()
      .value()


module.exports = Linter
