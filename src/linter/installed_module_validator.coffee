_ = require 'lodash'
async = require 'async'
fs = require 'fs'
fsExtra = require 'fs-extra'
path = require 'path'
semver = require 'semver'


class InstalledModuleValidater

  validate: ({dir, packageJson}, done) ->
    modules = _.assign {}, packageJson.dependencies, packageJson.devDependencies
    issues = []
    iterator = (version, name, next) =>
      if not semver.validRange(version) then return next()
      @validateModule {dir, name, version}, (err, status) ->
        if err then return next err
        if status then issues.push {name, status}
        next()
    async.forEachOf modules, iterator, (err) =>
      if err then return done err
      if issues.length is 0 then return done()
      done new Error @buildErrorMessage(issues)


  validateModule: ({dir, name, version}, done) ->
    modulePackageJsonPath = path.join dir, 'node_modules', name, 'package.json'
    fs.access modulePackageJsonPath, (err) ->
      if err then return done null, 'not installed'
      fsExtra.readJson modulePackageJsonPath, (err, modulePackageJson) ->
        if err then return done err
        if semver.satisfies modulePackageJson.version, version
          done()
        else
          done null, "installed: #{modulePackageJson.version}, listed: #{version}"


  buildErrorMessage: (issues) ->
    issueMessages = issues.map ({name, status}) -> "#{name} (#{status})"
    """
    The following modules listed in your `package.json` have issues:
      #{issueMessages.join '\n  '}
    All modules need to be installed with the correct semantic version
    to properly check for the usage of a module's executables.
    """


module.exports = InstalledModuleValidater
