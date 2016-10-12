builtIns = require 'builtin-modules'
globalExecutables = ['npm']


ModuleNameParser =

  isBuiltIn: (name) -> name in builtIns

  isGlobalExecutable: (name) -> name in globalExecutables

  isRelative: (name) -> name[0] is '.'

  stripLoaders: (name) ->
    [..., name] = name.split '!'
    name

  stripSubpath: (name) ->
    parts = name.split '/'
    if name[0] is '@'
      parts.slice(0, 2).join '/'
    else
      parts[0]


module.exports = ModuleNameParser
