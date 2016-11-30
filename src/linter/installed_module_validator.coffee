_ = require 'lodash'
fs = require 'fs'
fsExtra = require 'fs-extra'
path = require 'path'
Promise = require 'bluebird'
semver = require 'semver'


{coroutine} = Promise
access = Promise.promisify fs.access
readJson = Promise.promisify fsExtra.readJson


class InstalledModuleValidater

  validate: coroutine ({dir, packageJson}) ->
    modules = _.assign {}, packageJson.devDependencies, packageJson.dependencies
    issues = []
    yield Promise.all _.map modules, coroutine (version, name) =>
      return unless semver.validRange version
      status = yield @getModuleStatus {dir, name, version}
      return unless status
      issues.push {name, status}
    return unless issues.length
    throw new Error @buildErrorMessage(issues)


  getModuleStatus: coroutine ({dir, name, version}) ->
    modulePackageJsonPath = path.join dir, 'node_modules', name, 'package.json'
    try
      yield access modulePackageJsonPath
    catch
      return 'not installed'
    modulePackageJson = yield readJson modulePackageJsonPath
    return if semver.satisfies modulePackageJson.version, version
    "installed: #{modulePackageJson.version}, listed: #{version}"


  buildErrorMessage: (issues) ->
    issueMessages = issues.map ({name, status}) -> "#{name} (#{status})"
    """
    The following modules listed in your `package.json` have issues:
      #{issueMessages.join '\n  '}
    All modules need to be installed with the correct semantic version
    to properly check for the usage of a module's executables.
    """


module.exports = InstalledModuleValidater
