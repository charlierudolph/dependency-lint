trimLines = (str) ->
  str
    .trim()
    .split '\n'
    .map (line) -> line.trim()
    .join '\n'


module.exports = {trimLines}
