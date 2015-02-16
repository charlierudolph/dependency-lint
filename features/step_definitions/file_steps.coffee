async = require 'async'
fs = require 'fs-extra'
path = require 'path'
{addToJsonFile} = require '../support/json_helpers'


module.exports = ->

  @Given /^I have a file "([^"]*)" which requires "([^"]*)"$/, (file, module, done) ->
    fs.outputFile path.join(@tmpDir, file), "require '#{module}'", done


  @Given /^I have a file "([^"]*)" which resolves "([^"]*)"$/, (file, module, done) ->
    fs.outputFile path.join(@tmpDir, file), "require.resolve '#{module}'", done


  @Given /^I have configured "([^"]*)" to contain "([^"]*)"$/, (key, value, done) ->
    json = {}
    json[key] = [value]
    addToJsonFile path.join(@tmpDir, 'dependency-lint.json'), json, done


  @Given /^I have no (.*) listed$/, (key, done) ->
    json = {}
    json[key] = []
    addToJsonFile path.join(@tmpDir, 'package.json'), json, done


  @Given /^I have "([^"]*)"( installed and)? listed as a (.*)$/, (module, installed, type, done) ->
    actions = [
      (taskDone) =>
        key = type.replace 'y', 'ies'
        json = {}
        json[key] = {}
        json[key][module] = '0.0.1'
        addToJsonFile path.join(@tmpDir, 'package.json'), json, taskDone
    ]
    actions.push(
      (taskDone) =>
        addToJsonFile(
          path.join(@tmpDir, 'node_modules', module, 'package.json'),
          name: module,
          taskDone)
    ) if installed
    async.parallel actions, done


  @Given /^I have a script named "([^"]*)" defined as "([^"]*)"$/, (name, command, done) ->
    scripts = {}
    scripts[name] = command
    addToJsonFile path.join(@tmpDir, 'package.json'), {scripts}, done


  @Given /^the "([^"]*)" module exposes the executable "([^"]*)"$/, (module, executable, done) ->
    json = {name: module, bin: {}}
    json.bin[executable] = ''
    addToJsonFile path.join(@tmpDir, 'node_modules', module, 'package.json'), json, done


  @Then /^now I have the file "([^"]*)" with the default config$/, (filename, done) ->
    defaultConfigPath = path.join __dirname, '..', '..', 'config', 'default.json'
    fs.readFile defaultConfigPath, encoding: 'utf8', (err, data) =>
      if err then return done err
      expect(path.join @tmpDir, filename).to.have.content data
      done()
