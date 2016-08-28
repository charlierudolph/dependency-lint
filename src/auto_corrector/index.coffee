_ = require 'lodash'
ERRORS = require '../errors'
fsExtra = require 'fs-extra'
path = require 'path'
Promise = require 'bluebird'
sortedObject = require 'sorted-object'


writeJson = Promise.promisify fsExtra.writeJson


class AutoCorrector

  correct: ({packageJson, results}) ->
    {changes, fixes} = @getChanges results
    updatedPackageJson = @applyChanges {changes, packageJson}
    {fixes, updatedPackageJson}


  getChanges: (results) ->
    changes = []
    fixes = dependencies: [], devDependencies: []
    for type, modules of results
      for module in modules
        change = @getChange {module, type}
        if change
          changes.push change
          fixes[type].push module.name
    {changes, fixes}


  getChange: ({module, type}) ->
    switch module.error
      when ERRORS.SHOULD_BE_DEPENDENCY, ERRORS.SHOULD_BE_DEV_DEPENDENCY
        (packageJson) ->
          newType = if type is 'dependencies' then 'devDependencies' else 'dependencies'
          version = packageJson[type][module.name]
          delete packageJson[type][module.name]
          packageJson[newType] or= {}
          packageJson[newType][module.name] = version
          packageJson[newType] = sortedObject packageJson[newType]
      when ERRORS.UNUSED
        (packageJson) ->
          delete packageJson[type][module.name]


  applyChanges: ({changes, packageJson}) ->
    updatedPackageJson = _.cloneDeep packageJson
    change(updatedPackageJson) for change in changes
    updatedPackageJson


module.exports = AutoCorrector
