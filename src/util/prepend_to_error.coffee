prependUnlessPresent = (str, prefix) ->
  if str.indexOf(prefix) is -1
    [prefix, str].join ': '
  else
    str


prependToError = (prefix) ->
  (err) ->
    err.message = prependUnlessPresent err.message, prefix
    throw err


module.exports = prependToError
