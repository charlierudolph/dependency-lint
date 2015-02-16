trimLines = (str) ->
  str.split('\n').map((line) -> line.trim()).join('\n')


module.exports = {trimLines}
