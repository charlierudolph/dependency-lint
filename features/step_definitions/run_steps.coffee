{execFile} = require 'child_process'
path = require 'path'
{trimLines} = require '../support/string_helpers'


module.exports = ->

  @When /^I run "dependency-lint([^"]*)"$/, (args, done) ->
    execFile(
      path.join(__dirname, '..', '..', 'bin', 'dependency-lint.js'),
      args.trim().split(' '),
      cwd: @tmpDir,
      (@error, @stdout, @stderr) => done()
    )


  @Then /^I see the output$/, (output, done) ->
    expect(trimLines(@stdout)).to.contain trimLines(output)
    done()


  @Then /^I see the error$/, (error, done) ->
    expect(trimLines(@stderr)).to.contain trimLines(error)
    done()


  @Then /^it exits with a non\-zero status$/, (done) ->
    @errorExpected = true
    expect(@error).to.exist
    done()
