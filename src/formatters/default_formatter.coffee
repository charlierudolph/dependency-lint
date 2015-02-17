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


  moduleOutput: ({error, files, name, scripts, warning}) ->
    if error
      colors.red("✖ #{name} (#{error})") + colors.gray(@errorSuffix {files, scripts})
    else if warning
      colors.yellow "- #{name} (#{warning})"
    else
      "#{colors.green '✓'} #{name}"


  indent: (str, count) ->
    prefix = ''
    prefix += '  ' for [1..count]
    prefix + str


  write: (data, indent = 0) ->
    data = data.split('\n').map((str) => @indent str, indent).join('\n') + '\n'
    @stream.write data, 'utf8'


  errorCount: (results) ->
    errors = 0
    for title, modules of results
      errors += 1 for {error} in modules when error
    errors


  errorSuffix: (usage) ->
    suffix = ''
    for type, list of usage when list and list.length > 0
      suffix += '\n' + @indent "used in #{type}:", 2
      suffix += '\n' + @indent item, 3 for item in list
    suffix


  summaryOutput: (results) ->
    errors = @errorCount results
    prefix = colors.green '✓'
    prefix = colors.red '✖' if errors > 0
    msg = "#{prefix} #{errors} error"
    msg += 's' if errors isnt 1
    msg


module.exports = DefaultFormatter
