_ = require 'lodash'
async = require 'async'
fs = require 'fs'
fsExtra = require 'fs-extra'
path = require 'path'
{addToJsonFile, addToYmlFile} = require '../support/file_helpers'


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


  @Given /^I have configured "([^"]*)" to contain "([^"]*)"$/, (key, value, done) ->
    filePath = path.join @tmpDir, 'dependency-lint.yml'
    content = {}
    content[key] = [value]
    addToYmlFile filePath, content, done


  @Given /^I have configured "([^"]*)" to contain$/, (key, table, done) ->
    filePath = path.join @tmpDir, 'dependency-lint.yml'
    content = {}
    content[key] = table.hashes()
    addToYmlFile filePath, content, done


  @Given /^I have configured "([^"]*)" to be "([^"]*)"$/, (key, value, done) ->
    filePath = path.join @tmpDir, 'dependency-lint.yml'
    content = {}
    content[key] = value
    addToYmlFile filePath, content, done


  @Given /^I have configured "([^"]*)" to be true$/, (key, done) ->
    filePath = path.join @tmpDir, 'dependency-lint.yml'
    content = {}
    content[key] = true
    addToYmlFile filePath, content, done


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
    nodeModulesPath = path.join @tmpDir, 'node_modules'
    nodeModulesBinPath = path.join nodeModulesPath, '.bin'
    executablePath = path.join nodeModulesPath, name, 'path', 'to', 'executable'
    async.series [
      (next) ->
        fsExtra.outputFile executablePath, '', next
      (next) ->
        src = path.relative nodeModulesBinPath, executablePath
        dest = path.join nodeModulesBinPath, executable
        fsExtra.ensureSymlink src, dest, next
    ], done


  @Then /^now I have the file "([^"]*)" with the default config$/, (filename, done) ->
    filePaths = [
      path.join __dirname, '..', '..', 'config', "default#{path.extname filename}"
      path.join @tmpDir, filename
    ]
    iterator = (filePath, next) ->
      fs.readFile filePath, encoding: 'utf8', next
    callback = (err, [defaultConfigContent, fileContent] = []) ->
      if err then return done err
      expect(fileContent).to.eql defaultConfigContent
      done()
    async.map filePaths, iterator, callback
