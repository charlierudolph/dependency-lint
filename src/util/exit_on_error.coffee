colors = require 'colors/safe'


exitOnError = (err) ->
  if err
    console.error colors.red(err.toString())
    process.exit 1


module.exports = exitOnError
