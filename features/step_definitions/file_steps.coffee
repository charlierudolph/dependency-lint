async = require 'async'
fs = require 'fs-extra'
path = require 'path'
{addToJsonFile} = require '../support/json_helpers'


module.exports = ->

  @Given /^I have a file "([^"]*)" which requires "([^"]*)"$/, (file, module, done) ->
    fs.outputFile path.join(@tmpDir, file), "require '#{module}'", done


  @Given /^I have a file "([^"]*)" which resolves "([^"]*)"$/, (file, module, done) ->
    fs.outputFile path.join(@tmpDir, file), "require.resolve '#{module}'", done


  @Given /^I have a file "([^"]*)" with a coffeescript compilation error$/, (file, done) ->
    fs.outputFile path.join(@tmpDir, file), "require '", done


  @Given /^I have configured "([^"]*)" to contain "([^"]*)"$/, (key, value, done) ->
    filePath = path.join @tmpDir, 'dependency-lint.json'
    content = {}
    content[key] = [value]
    addToJsonFile filePath, content, done


  @Given /^I have no (.*) listed$/, (key, done) ->
    filePath = path.join @tmpDir, 'package.json'
    content = {}
    content[key] = []
    addToJsonFile filePath, content, done


  @Given /^I have "([^"]*)" installed$/, (name, done) ->
    filePath = path.join @tmpDir, 'node_modules', name, 'package.json'
    content = {name}
    addToJsonFile filePath, content, done


  @Given /^I have "([^"]*)" listed as a (.*)$/, (name, type, done) ->
    filePath = path.join @tmpDir, 'package.json'
    key = type.replace 'y', 'ies'
    content = {}
    content[key] = {}
    content[key][name] = '0.0.1'
    addToJsonFile filePath, content, done


  @Given /^I have a script named "([^"]*)" defined as "([^"]*)"$/, (name, command, done) ->
    filePath = path.join @tmpDir, 'package.json'
    content = scripts: {}
    content.scripts[name] = command
    addToJsonFile filePath, content, done


  @Given /^the "([^"]*)" module exposes the executable "([^"]*)"$/, (name, executable, done) ->
    json = {name, bin: {}}
    json.bin[executable] = ''
    addToJsonFile path.join(@tmpDir, 'node_modules', name, 'package.json'), json, done


  @Then /^now I have the file "([^"]*)" with the default (.+) config$/, (filename, ext, done) ->
    filePaths = [
      path.join __dirname, '..', '..', 'config', "default.#{ext}"
      path.join @tmpDir, filename
    ]
    iterator = (filePath, next) ->
      fs.readFile filePath, encoding: 'utf8', next
    callback = (err, [defaultConfigContent, fileContent] = []) ->
      if err then return done err
      expect(fileContent).to.eql defaultConfigContent
      done()
    async.map filePaths, iterator, callback
