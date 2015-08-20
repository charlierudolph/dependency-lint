builtIns = [
  'assert', 'buffer', 'child_process', 'cluster', 'crypto', 'dgram', 'dns', 'domain', 'events',
  'fs', 'http', 'https', 'net', 'os', 'path', 'punycode', 'querystring', 'readline', 'reply',
  'stream', 'string_decoder', 'tls', 'tty', 'url', 'util', 'vm', 'zlib'
]


globalExecutables = [
  'npm'
]


ModuleNameParser =

  isBuiltIn: (name) -> name in builtIns

  isGlobalExecutable: (name) -> name in globalExecutables

  isRelative: (name) -> name[0] is '.'

  stripSubpath: (name) ->
    parts = name.split '/'
    if name[0] is '@'
      parts.slice(0, 2).join '/'
    else
      parts[0]


module.exports = ModuleNameParser
