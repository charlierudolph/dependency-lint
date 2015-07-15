require 'fs-cson/register'
fs = require 'fs'
path = require 'path'
yaml = require 'js-yaml'

defaultCoffeeConfig = require './default.coffee'
defaultCsonConfig = require './default.cson'
defaultJsConfig = require './default.js'
defaultJsonConfig = require './default.json'
defaultYamlConfig = yaml.safeLoad fs.readFileSync(path.join(__dirname, 'default.yaml'), 'utf8')
defaultYmlConfig = yaml.safeLoad fs.readFileSync(path.join(__dirname, 'default.yml'), 'utf8')


describe 'default configs', ->
  it 'coffee, cson, js, json and yaml are equivalent', ->
    expect(defaultCoffeeConfig).to.eql defaultCsonConfig
    expect(defaultCoffeeConfig).to.eql defaultJsConfig
    expect(defaultCoffeeConfig).to.eql defaultJsonConfig
    expect(defaultCoffeeConfig).to.eql defaultYamlConfig
    expect(defaultCoffeeConfig).to.eql defaultYmlConfig
