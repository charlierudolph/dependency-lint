_ = require 'lodash'
fs = require 'fs'
glob = require 'glob'
path = require 'path'


class ExecutedModulesFinder

  constructor: ({@devScripts, @dir}) ->
    {@scripts, dependencies, devDependencies} = require path.join(@dir, 'package.json')
    @scripts ?= {}
    @modulesListed = _.keys(dependencies).concat _.keys(devDependencies)


  find: (done) ->
    @getModuleExecutables (err, moduleExecutables) =>
      if err then return done err
      result = dev: [], prod: []
      for name, script of @scripts
        for module, executables of moduleExecutables
          for executable in executables when script.match executable
            key = if @isDevScript name then 'dev' else 'prod'
            result[key].push module
      done null, result


  allModulesInstalled: (moduleExecutables) ->
    _.difference(@modulesListed, _.keys(moduleExecutables)).length is 0


  ensureAllModulesInstalled: (moduleExecutables, done) ->
    if @allModulesInstalled moduleExecutables
      done null, moduleExecutables
    else
      done new Error '''
        You have uninstalled modules listed in your package. Please run `npm install`.
        dependency-lint needs all modules to be installed in order to search module executables.
        '''


  getModuleExecutables: (done) ->
    glob "#{@dir}/node_modules/*/package.json", (err, files) =>
      if err then return done err
      result = []
      for file in files
        {name, bin} = require(file)
        result[name] = _.keys(bin)
      @ensureAllModulesInstalled result, done


  isDevScript: (name) ->
    for regex in @devScripts
      return yes if name.match regex
    no


module.exports = ExecutedModulesFinder
