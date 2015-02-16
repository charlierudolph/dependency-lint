_ = require 'lodash'
colors = require 'colors/safe'


class DefaultFormatter

  # stream - writable stream to send output
  constructor: ({@stream}) ->


  # Prints the result to its stream
  print: (results) ->
    for title, modules of results when modules.length isnt 0
      @write ''
      @write "#{title}:", 1
      for module in modules
        @write @moduleOutput(module), 2
    @write ''
    @write @summaryOutput(results), 1
    @write ''


  moduleOutput: ({error, name, warning}) ->
    if error
      colors.red "✖ #{name} (#{error})"
    else if warning
      colors.yellow "- #{name} (#{warning})"
    else
      "#{colors.green '✓'} #{name}"


  write: (data, indent = 0) ->
    prefix = ''
    prefix += '  ' for [1..indent]
    @stream.write prefix + data + '\n', 'utf8'


  errorCount: (results) ->
    errors = 0
    for title, modules of results
      errors += 1 for {error} in modules when error
    errors


  summaryOutput: (results) ->
    errors = @errorCount results
    prefix = colors.green '✓'
    prefix = colors.red '✖' if errors > 0
    msg = "#{prefix} #{errors} error"
    msg += 's' if errors isnt 1
    msg


module.exports = DefaultFormatter
