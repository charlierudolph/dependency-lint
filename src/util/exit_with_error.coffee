colors = require 'colors/safe'
util = require 'util'


exitWithError = (err) ->
  message = err?.stack or util.format(err)
  console.error colors.red(message)
  process.exit 1


module.exports = exitWithError
