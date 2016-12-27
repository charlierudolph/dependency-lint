_ = require 'lodash'
{addToJsonFile, addToYmlFile} = require '../support/file_helpers'
fs = require('fs')
fsExtra = require('fs-extra')
path = require 'path'
Promise = require 'bluebird'
yaml = require 'js-yaml'


ensureSymlink = Promise.promisify fsExtra.ensureSymlink
readFile = Promise.promisify fs.readFile
readJson = Promise.promisify fsExtra.readJson
outputFile = Promise.promisify fsExtra.outputFile


module.exports = ->

  @Given /^I have a file "([^"]*)" which requires "([^"]*)"$/, (file, module) ->
    content = if path.extname(file) is '.coffee'
      "require '#{module}'"
    else
      "require('#{module}')"
    yield outputFile path.join(@tmpDir, file), content


  @Given /^I have a file "([^"]*)" which resolves "([^"]*)"$/, (file, module) ->
    yield outputFile path.join(@tmpDir, file), "require.resolve('#{module}')"


  @Given /^I have a file "([^"]*)" with a coffeescript compilation error$/, (file) ->
    yield outputFile path.join(@tmpDir, file), "require '"


  @Given /^I have a file "([^"]*)" with the content:$/, (file, content) ->
    yield outputFile path.join(@tmpDir, file), content


  @Given /^I have configured "([^"]*)" to contain "([^"]*)"$/, (key, value) ->
    filePath = path.join @tmpDir, 'dependency-lint.yml'
    content = {}
    _.set content, key, [value]
    yield addToYmlFile filePath, content


  @Given /^I have configured "([^"]*)" to contain$/, (key, table) ->
    filePath = path.join @tmpDir, 'dependency-lint.yml'
    value = table.hashes().map (obj) -> _.mapKeys obj, (v, k) -> k.toLowerCase()
    content = {}
    _.set content, key, value
    yield addToYmlFile filePath, content


  @Given /^I have configured "([^"]*)" to be "([^"]*)"$/, (key, value) ->
    filePath = path.join @tmpDir, 'dependency-lint.yml'
    content = {}
    _.set content, key, value
    yield addToYmlFile filePath, content


  @Given /^I have configured "([^"]*)" to be true$/, (key) ->
    filePath = path.join @tmpDir, 'dependency-lint.yml'
    content = {}
    _.set content, key, true
    yield addToYmlFile filePath, content


  @Given /^I have no (.*) listed$/, (key) ->
    filePath = path.join @tmpDir, 'package.json'
    content = {}
    content[key] = []
    yield addToJsonFile filePath, content


  @Given /^I have "([^"]*)" installed$/, (nameAndVersion) ->
    [name, version] = nameAndVersion.split ' @ '
    version or= '1.0.0'
    filePath = path.join @tmpDir, 'node_modules', name, 'package.json'
    content = {name, version}
    yield addToJsonFile filePath, content


  @Given /^I have "([^"]*)" listed as a (.*)$/, (nameAndVersion, type) ->
    filePath = path.join @tmpDir, 'package.json'
    key = type.replace 'y', 'ies'
    [name, version] = nameAndVersion.split ' @ '
    version or= '^1.0.0'
    content = {}
    content[key] = {}
    content[key][name] = version
    yield addToJsonFile filePath, content


  @Given /^I have a script named "([^"]*)" defined as "([^"]*)"$/, (name, command) ->
    filePath = path.join @tmpDir, 'package.json'
    content = scripts: {}
    content.scripts[name] = command
    yield addToJsonFile filePath, content


  @Given /^the "([^"]*)" module exposes the executable "([^"]*)"$/, (name, executable) ->
    filePath = path.join @tmpDir, 'node_modules', name, 'package.json'
    content = {name, bin: {"#{executable}": 'path/to/executable'}}
    yield addToJsonFile filePath, content


  @Then /^now I have the file "([^"]*)" with the default config$/, (filename) ->
    filePaths = [
      path.join __dirname, '..', '..', 'config', "default.yml"
      path.join @tmpDir, filename
    ]
    promises = filePaths.map (filePath) -> yield readFile filePath, 'utf8'
    [defaultConfigContent, userConfigContent] = yield Promise.all promises
    defaultConfig = yaml.load defaultConfigContent
    userConfig = yaml.load userConfigContent
    expect(defaultConfig).to.eql userConfig


  @Then /^(?:now I|I still)( no longer)? have "([^"]*)" listed as a (.*)$/, (negate, name, type) ->
    filePath = path.join @tmpDir, 'package.json'
    content = yield readJson filePath
    key = type.replace 'y', 'ies'
    value = content[key][name]
    if negate
      expect(value).to.not.exist
    else
      expect(value).to.exist


  @Then /^"([^"]*)" contains$/, (filename, content) ->
    filePath = path.join @tmpDir, filename
    fileContent = yield readFile filePath, 'utf8'
    version = require('../../package.json').version
    content = content.replace '{{version}}', version
    expect(fileContent).to.contain content
