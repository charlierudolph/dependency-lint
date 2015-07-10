filterExecutedModules = (moduleNames) ->
  {globalModules} = require '../module_db'
  moduleNames
    .filter (name) -> name not in globalModules


filterRequiredModules = (moduleNames) ->
  {builtInModules} = require '../module_db'
  moduleNames
    .filter (name) ->
      name[0] isnt '.' and
      name not in builtInModules
    .map (name) ->
      parts = name.split '/'
      if name[0] is '@'
        parts.slice(0, 2).join '/'
      else
        parts[0]


module.exports = {filterExecutedModules, filterRequiredModules}
