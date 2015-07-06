_ = require 'lodash'
{globalModules} = require './module_db'
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
      for name in modules when not _.any(usedModules, (moduleData) -> moduleData.name is name)
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
    return yes for regex in @allowUnused when name.match regex
    no


  isDevDependency: ({files, scripts}) ->
    for file in files
      return no unless @isDevFile file
    for script in scripts
      return no unless @isDevScript script
    yes


  isDevFile: (file) ->
    return yes for pattern in @devFilePatterns when minimatch file, pattern
    no


  isDevScript: (script) ->
    return yes for regex in @devScripts when script.match regex
    no


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
