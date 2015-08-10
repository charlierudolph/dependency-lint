{execFile} = require 'child_process'
path = require 'path'
{trimLines} = require '../support/string_helpers'


module.exports = ->

  @When /^I run "dependency-lint([^"]*)"$/, (argStr, done) ->
    file = path.join __dirname, '..', '..', 'bin', 'dependency-lint.js'
    args = if argStr then argStr.trim().split(' ') else []
    options = cwd: @tmpDir
    execFile file, args, options, (@error, @stdout, @stderr) => done()


  @Then /^I see the output$/, (output) ->
    expect(trimLines(@stdout)).to.contain trimLines(output)


  @Then /^I see the error$/, (error) ->
    expect(trimLines(@stderr)).to.contain trimLines(error)


  @Then /^it exits with a non\-zero status$/, ->
    @errorExpected = true
    expect(@error).to.exist
