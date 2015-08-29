_ = require 'lodash'
async = require 'async'
asyncHandlers = require 'async-handlers'
fs = require 'fs'
glob = require 'glob'
ModuleNameParser = require './module_name_parser'
path = require 'path'


class ExecutedModulesFinder

  find: (dir, done) ->
    {scripts, dependencies, devDependencies} = require path.join(dir, 'package.json')
    scripts = {} unless scripts
    callback = ([_, moduleExecutables]) => @findModuleExecutableUsage {moduleExecutables, scripts}
    async.parallel [
      (next) =>
        modulesListed = _.keys(dependencies).concat _.keys(devDependencies)
        @ensureAllModulesInstalled {dir, modulesListed}, next
      (next) =>
        @getModuleExecutables dir, next
    ], asyncHandlers.transform(callback, done)


  ensureAllModulesInstalled: ({dir, modulesListed}, done) ->
    missing = []
    iterator = (moduleName, next) ->
      fs.access path.join(dir, 'node_modules', moduleName), (err) ->
        if err then missing.push moduleName
        next()
    callback = (err) ->
      if err then return done err
      if missing.length is 0 then return done()
      done new Error """
        The following modules are listed in your `package.json` but are not installed.
          #{missing.join '\n  '}
        All modules need to be installed to properly check for the usage of a module's executables.
        """
    async.each modulesListed, iterator, callback


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
    async.auto {
      files: (next) -> glob "#{dir}/node_modules/.bin/*", next
      links: ['files', (next, {files}) -> async.map files, fs.readlink, next]
    }, asyncHandlers.transform(@parseModuleExecutables, done)


  parseModuleExecutables: ({files, links}) ->
    result = {}
    executables = files.map (file) -> path.basename file
    links.forEach (link, index) ->
      name = ModuleNameParser.stripSubpath path.relative('..', link)
      result[name] = [] unless result[name]
      result[name].push path.basename executables[index]
    result


module.exports = ExecutedModulesFinder
