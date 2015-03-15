_ = require 'lodash'
{builtInModules, globalModules} = require '../module_db'


class ModuleFilterer

  filterExecutedModules: (moduleNames) ->
    _.chain(moduleNames)
      .filter (name) ->
        name not in globalModules
      .value()


  filterRequiredModules: (moduleNames) ->
    _.chain(moduleNames)
      .filter (name) ->
        name[0] isnt '.' and
        name not in builtInModules
      .map (name) ->
        name.replace /\/.*$/, ''
      .value()


module.exports = ModuleFilterer
