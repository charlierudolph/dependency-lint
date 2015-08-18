{addToJsonFile} = require '../support/json_helpers'
path = require 'path'
Promise = require 'bluebird'

readFile = Promise.promisify require('fs').readFile
outputFile = Promise.promisify require('fs-extra').outputFile


module.exports = ->

  @Given /^I have a file "([^"]*)" which requires "([^"]*)"$/, (file, module) ->
    outputFile path.join(@tmpDir, file), "require '#{module}'"


  @Given /^I have a file "([^"]*)" which resolves "([^"]*)"$/, (file, module) ->
    outputFile path.join(@tmpDir, file), "require.resolve '#{module}'"


  @Given /^I have a file "([^"]*)" with a coffeescript compilation error$/, (file) ->
    outputFile path.join(@tmpDir, file), "require '"


  @Given /^I have configured "([^"]*)" to contain "([^"]*)"$/, (key, value) ->
    filePath = path.join @tmpDir, 'dependency-lint.json'
    content = {}
    content[key] = [value]
    addToJsonFile filePath, content


  @Given /^I have no (.*) listed$/, (key) ->
    filePath = path.join @tmpDir, 'package.json'
    content = {}
    content[key] = []
    addToJsonFile filePath, content


  @Given /^I have "([^"]*)" installed$/, (name) ->
    filePath = path.join @tmpDir, 'node_modules', name, 'package.json'
    content = {name}
    addToJsonFile filePath, content


  @Given /^I have "([^"]*)" listed as a (.*)$/, (name, type) ->
    filePath = path.join @tmpDir, 'package.json'
    key = type.replace 'y', 'ies'
    content = {}
    content[key] = {}
    content[key][name] = '0.0.1'
    addToJsonFile filePath, content


  @Given /^I have a script named "([^"]*)" defined as "([^"]*)"$/, (name, command) ->
    filePath = path.join @tmpDir, 'package.json'
    content = scripts: {}
    content.scripts[name] = command
    addToJsonFile filePath, content


  @Given /^the "([^"]*)" module exposes the executable "([^"]*)"$/, (name, executable) ->
    json = {name, bin: {}}
    json.bin[executable] = ''
    addToJsonFile path.join(@tmpDir, 'node_modules', name, 'package.json'), json


  @Then /^now I have the file "([^"]*)" with the default config$/, (filename) ->
    filePaths = [
      path.join __dirname, '..', '..', 'config', "default#{path.extname filename}"
      path.join @tmpDir, filename
    ]
    Promise.resolve filePaths
      .map (filePath) -> readFile filePath, 'utf8'
      .then ([defaultConfigContent, fileContent]) ->
        expect(fileContent).to.eql defaultConfigContent
