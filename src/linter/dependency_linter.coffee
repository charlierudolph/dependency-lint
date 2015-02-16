_ = require 'lodash'


class DependencyLinter

  constructor: ({@ignoreUnused}) ->


  # Lints the used and listed modules
  #
  # dependencies - {used, listed} where each is an array of module names
  # devDependencies - {used, listed} where each is an array of module names
  #
  # Returns {dependencies, devDependencies} where each is an array of {error, name, warning}
  lint: ({dependencies, devDependencies}) ->
    devDependencies.used = _.difference devDependencies.used, dependencies.used

    [missingDependencies,
     devDependenciesShouldBeDependencies,
     unusedDevDependencies] = @partition @missing(dependencies), @unused(devDependencies)

    [missingDevDependencies,
     dependenciesShouldBeDevDependencies,
     unusedDependencies] = @partition @missing(devDependencies), @unused(dependencies)

    dependencies: @buildList @passing(dependencies), {
      missing: missingDependencies
      'should be devDependency': dependenciesShouldBeDevDependencies
      unused: unusedDependencies
    }
    devDependencies: @buildList @passing(devDependencies), {
      missing: missingDevDependencies
      'should be dependency': devDependenciesShouldBeDependencies
      unused: unusedDevDependencies
    }


  buildList: (passing, errors) ->
    list = []
    list.push {name: moduleName} for moduleName in passing
    for error, moduleNames of errors
      for moduleName in moduleNames
        if error is 'unused' and @isInIgnoredUnused moduleName
          list.push {name: moduleName, warning: 'unused but ignored'}
        else
          list.push {name: moduleName, error}
    _.sortBy list, 'name'


  isInIgnoredUnused: (moduleName) ->
    _.any @ignoreUnused, (regex) -> moduleName.match regex


  passing: ({used, listed}) ->
    _.intersection used, listed


  missing: ({used, listed}) ->
    _.difference used, listed


  unused: ({used, listed}) ->
    _.difference listed, used


  # Parititons two arrays into those unique to each array and the intersection
  #
  # Returns an array of length 3
  # array[0] is the values unique to list1
  # array[1] is the intersection
  # array[2] is the values unique to list2
  partition: (list1, list2) ->
    intersection = _.intersection list1, list2
    [
      _.difference list1, intersection
      intersection
      _.difference list2, intersection
    ]


module.exports = DependencyLinter
