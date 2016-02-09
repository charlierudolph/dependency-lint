_ = require 'lodash'
minimatch = require 'minimatch'


class DependencyLinter

  constructor: ({@allowUnused, @devFilePatterns, @devScripts}) ->


  # Lints the used and listed modules
  #
  # listedModules - {dependencies, devDependencies} where each is an array of module names
  # usedModules - array of {name, files, scripts}
  #
  # Returns {dependencies, devDependencies}
  #         where each is an array of {name, files, scripts, error, warning}
  lint: ({listedModules, usedModules}) =>
    result =
      dependencies: []
      devDependencies: []

    for usedModule in usedModules
      status =
        isDependency: not @isDevDependency usedModule
        listedAsDependency: usedModule.name in listedModules.dependencies
        listedAsDevDependency: usedModule.name in listedModules.devDependencies
      @parseUsedModule usedModule, status, result

    for key, modules of listedModules
      for name in modules when not _.some(usedModules, (moduleData) -> moduleData.name is name)
        listedModule = {name}
        if @allowedToBeUnused name
          listedModule.warning = 'unused - allowed'
        else
          listedModule.error = 'unused'
        result[key].push listedModule

    result.dependencies = _.sortBy result.dependencies, 'name'
    result.devDependencies = _.sortBy result.devDependencies, 'name'
    result


  allowedToBeUnused: (name) ->
    _.some @allowUnused, (regex) -> name.match regex


  isDevDependency: ({files, scripts}) ->
    _.every(files, @isDevFile) and _.every(scripts, @isDevScript)


  isDevFile: (file) =>
    _.some @devFilePatterns, (pattern) -> minimatch file, pattern


  isDevScript: (script) =>
    _.some @devScripts, (regex) -> script.match regex


  parseUsedModule: (usedModule, status, result) ->
    {isDependency, listedAsDependency, listedAsDevDependency} = status
    if isDependency
      if listedAsDependency
        result.dependencies.push usedModule
      if listedAsDevDependency
        result.devDependencies.push _.assign {}, usedModule, {error: 'should be dependency'}
      unless listedAsDependency or listedAsDevDependency
        result.dependencies.push _.assign {}, usedModule, {error: 'missing'}
    else
      if listedAsDependency
        result.dependencies.push _.assign {}, usedModule, {error: 'should be devDependency'}
      if listedAsDevDependency
        result.devDependencies.push usedModule
      unless listedAsDependency or listedAsDevDependency
        result.devDependencies.push _.assign {}, usedModule, {error: 'missing'}


module.exports = DependencyLinter
