_ = require 'lodash'
async = require 'async'
asyncHandlers = require 'async-handlers'
fs = require 'fs'
ModuleNameParser = require './module_name_parser'
path = require 'path'


class ExecutedModulesFinder

  find: ({dir, packageJson}, done) ->
    scripts = packageJson.scripts or {}
    callback = (moduleExecutables) => @findModuleExecutableUsage {moduleExecutables, scripts}
    @getModuleExecutables dir, asyncHandlers.transform(callback, done)


  findInScript: (script, moduleExecutables) ->
    result = []
    for moduleName, executables of moduleExecutables
      for executable in executables
        continue if ModuleNameParser.isGlobalExecutable executable
        result.push moduleName if script.match(executable) and moduleName not in result
    result


  findModuleExecutableUsage: ({moduleExecutables, scripts}) =>
    result = []
    for scriptName, script of scripts
      for moduleName in @findInScript script, moduleExecutables
        result.push {name: moduleName, script: scriptName}
    result


  getModuleExecutables: (dir, done) ->
    binPath = path.join dir, 'node_modules', '.bin'
    async.auto {
      executables: (next) ->
        fs.access binPath, (err) ->
          if err then return done null, []
          fs.readdir binPath, next

      links: ['executables', (next, {executables}) ->
        files = executables.map (file) -> path.join binPath, file
        async.map files, fs.readlink, next
      ]
    }, asyncHandlers.transform(@parseModuleExecutables, done)


  parseModuleExecutables: ({executables, links}) ->
    result = {}
    links.forEach (link, index) ->
      name = ModuleNameParser.stripSubpath path.relative('..', link)
      result[name] = [] unless result[name]
      result[name].push path.basename executables[index]
    result


module.exports = ExecutedModulesFinder
