prependUnlessPresent = (str, prefix) ->
  if str.indexOf(prefix) is -1
    [prefix, str].join ': '
  else
    str


prependToError = (err, prefix) ->
  err.message = prependUnlessPresent err.message, prefix
  err


module.exports = prependToError
