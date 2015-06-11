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
  lint: ({listedModules, usedModules}) ->
    result =
      dependencies: []
      devDependencies: []

    for {name, files, scripts} in usedModules
      isDependency = @isDependency files, scripts
      listedAsDependency = name in listedModules.dependencies
      listedAsDevDependency = name in listedModules.devDependencies
      status = @status {isDependency, listedAsDependency, listedAsDevDependency}
      key = if listedAsDependency or (not listedAsDevDependency and isDependency)
        'dependencies'
      else
        'devDependencies'
      result[key].push _.assign {name, files, scripts}, status

    for key, modules of listedModules
      for name in modules when not _.any(usedModules, (moduleData) -> moduleData.name is name)
        moduleData = {name}
        if @allowedToBeUnused name
          moduleData.warning = 'unused - allowed'
        else
          moduleData.error = 'unused'
        result[key].push moduleData

    result.dependencies = _.sortBy result.dependencies, 'name'
    result.devDependencies = _.sortBy result.devDependencies, 'name'
    result


  allowedToBeUnused: (name) ->
    return yes for regex in @allowUnused when name.match regex
    no


  isDependency: (files, scripts) ->
    not @isDevDependency files, scripts


  isDevDependency: (files, scripts) ->
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


  status: ({isDependency, listedAsDependency, listedAsDevDependency}) ->
    if isDependency
      if listedAsDependency
        {}
      else if listedAsDevDependency
        {error: 'should be dependency'}
      else
        {error: 'missing'}
    else
      if listedAsDevDependency
        {}
      else if listedAsDependency
        {error: 'should be devDependency'}
      else
        {error: 'missing'}


module.exports = DependencyLinter
