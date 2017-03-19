_ = require 'lodash'
errorMessages = require './error_messages'


class JsonFormatter

  # stream - writable stream to send output
  constructor: ({@stream}) ->


  # Prints the result to its stream
  print: ({fixes = {}, results}) ->
    data = _.mapValues results, (modules, type) ->
      _.map modules, (module) ->
        fixed = _.includes fixes[type], module.name
        error = errorMessages[module.error]
        _.assign {}, module, {error, fixed}
    @stream.write JSON.stringify(data, null, 2), 'utf8'


module.exports = JsonFormatter
