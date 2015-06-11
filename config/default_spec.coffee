require 'fs-cson/register'
defaultCoffeeConfig = require './default.coffee'
defaultCsonConfig = require './default.cson'
defaultJsConfig = require './default.js'
defaultJsonConfig = require './default.json'


describe 'default configs', ->
  it 'coffee, cson, js, and json are equivalent', ->
    expect(defaultCoffeeConfig).to.eql defaultCsonConfig
    expect(defaultCoffeeConfig).to.eql defaultJsConfig
    expect(defaultCoffeeConfig).to.eql defaultJsonConfig
