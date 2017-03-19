{execFile} = require 'child_process'
path = require 'path'
{trimLines} = require '../support/string_helpers'


module.exports = ->

  @When /^I run it(?: with (--auto-correct|--generate-config))?(?: (?:with|and) the "([^"]*)" format)?$/, (option, format, done) ->
    file = path.join __dirname, '..', '..', 'bin', 'dependency-lint.js'
    args = ['--format', format or 'json']
    args.push option if option
    options = cwd: @tmpDir
    execFile file, args, options, (@error, @stdout, @stderr) => done()


  @Then /^I see the output$/, (output) ->
    expect(trimLines(@stdout)).to.eql trimLines(output)


  @Then /^I see no output$/, ->
    expect(@stdout).to.eql ''


  @Then /^I see the error$/, (error) ->
    expect(trimLines(@stderr)).to.contain trimLines(error)


  @Then /^it exits with a non\-zero status$/, ->
    @errorExpected = true
    expect(@error).to.exist


  @Then /^it reports no "([^"]*)"$/, (key) ->
    modules = JSON.parse(@stdout)[key]
    expect(modules).to.eql []


  @Then /^it reports the "([^"]*)":$/, (key, table) ->
    modules = JSON.parse(@stdout)[key]
    attributesList = table.hashes()
    expect(modules.length).to.eql attributesList.length
    attributesList.forEach (attributes, index) ->
      module = modules[index]
      expect(module.name).to.eql attributes.NAME
      expect(module.error).to.eql if attributes.ERROR is '<none>' then undefined else attributes.ERROR
      expect(module.errorIgnored).to.eql if attributes['ERROR IGNORED'] is 'true' then true else undefined
      expect(module.files).to.eql if attributes.FILES then attributes.FILES.split(', ') else []
      expect(module.fixed).to.eql attributes.FIXED is 'true'
      expect(module.scripts).to.eql if attributes.SCRIPTS then attributes.SCRIPTS.split(', ') else []
