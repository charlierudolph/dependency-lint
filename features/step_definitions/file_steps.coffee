_ = require 'lodash'
async = require 'async'
fs = require 'fs'
fsExtra = require 'fs-extra'
path = require 'path'
{addToJsonFile, addToYmlFile} = require '../support/file_helpers'
yaml = require 'js-yaml'


module.exports = ->

  @Given /^I have a file "([^"]*)" which requires "([^"]*)"$/, (file, module, done) ->
    content = if path.extname(file) is '.coffee'
      "require '#{module}'"
    else
      "require('#{module}')"
    fsExtra.outputFile path.join(@tmpDir, file), content, done


  @Given /^I have a file "([^"]*)" which resolves "([^"]*)"$/, (file, module, done) ->
    fsExtra.outputFile path.join(@tmpDir, file), "require.resolve('#{module}')", done


  @Given /^I have a file "([^"]*)" with a coffeescript compilation error$/, (file, done) ->
    fsExtra.outputFile path.join(@tmpDir, file), "require '", done


  @Given /^I have a file "([^"]*)" with the content:$/, (file, content, done) ->
    fsExtra.outputFile path.join(@tmpDir, file), content, done


  @Given /^I have configured "([^"]*)" to contain "([^"]*)"$/, (key, value, done) ->
    filePath = path.join @tmpDir, 'dependency-lint.yml'
    content = {}
    _.set content, key, [value]
    addToYmlFile filePath, content, done


  @Given /^I have configured "([^"]*)" to contain$/, (key, table, done) ->
    filePath = path.join @tmpDir, 'dependency-lint.yml'
    value = table.hashes().map (obj) -> _.mapKeys obj, (v, k) -> k.toLowerCase()
    content = {}
    _.set content, key, value
    addToYmlFile filePath, content, done


  @Given /^I have configured "([^"]*)" to be "([^"]*)"$/, (key, value, done) ->
    filePath = path.join @tmpDir, 'dependency-lint.yml'
    content = {}
    _.set content, key, value
    addToYmlFile filePath, content, done


  @Given /^I have configured "([^"]*)" to be true$/, (key, done) ->
    filePath = path.join @tmpDir, 'dependency-lint.yml'
    content = {}
    _.set content, key, true
    addToYmlFile filePath, content, done


  @Given /^I have no (.*) listed$/, (key, done) ->
    filePath = path.join @tmpDir, 'package.json'
    content = {}
    content[key] = []
    addToJsonFile filePath, content, done


  @Given /^I have "([^"]*)" installed$/, (nameAndVersion, done) ->
    [name, version] = nameAndVersion.split ' @ '
    version or= '1.0.0'
    filePath = path.join @tmpDir, 'node_modules', name, 'package.json'
    content = {name, version}
    addToJsonFile filePath, content, done


  @Given /^I have "([^"]*)" listed as a (.*)$/, (nameAndVersion, type, done) ->
    filePath = path.join @tmpDir, 'package.json'
    key = type.replace 'y', 'ies'
    [name, version] = nameAndVersion.split ' @ '
    version or= '^1.0.0'
    content = {}
    content[key] = {}
    content[key][name] = version
    addToJsonFile filePath, content, done


  @Given /^I have a script named "([^"]*)" defined as "([^"]*)"$/, (name, command, done) ->
    filePath = path.join @tmpDir, 'package.json'
    content = scripts: {}
    content.scripts[name] = command
    addToJsonFile filePath, content, done


  @Given /^the "([^"]*)" module exposes the executable "([^"]*)"$/, (name, executable, done) ->
    filePath = path.join @tmpDir, 'node_modules', name, 'package.json'
    content = {name, bin: {"#{executable}": 'path/to/executable'}}
    addToJsonFile filePath, content, done


  @Then /^now I have the file "([^"]*)" with the default config$/, (filename, done) ->
    filePaths = [
      path.join __dirname, '..', '..', 'config', "default.yml"
      path.join @tmpDir, filename
    ]
    iterator = (filePath, next) ->
      fs.readFile filePath, encoding: 'utf8', next
    callback = (err, [defaultConfigContent, fileContent] = []) ->
      if err then return done err
      defaultConfig = yaml.load defaultConfigContent
      userConfig = yaml.load fileContent
      expect(userConfig).to.eql defaultConfig
      done()
    async.map filePaths, iterator, callback


  @Then /^"([^"]*)" contains$/, (filename, content, done) ->
    filePath = path.join @tmpDir, filename
    fs.readFile filePath, encoding: 'utf8', (err, fileContent) ->
      version = require('../../package.json').version
      content = content.replace '{{version}}', version
      expect(fileContent).to.contain content
      done()
