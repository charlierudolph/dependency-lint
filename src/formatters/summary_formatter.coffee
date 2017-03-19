_ = require 'lodash'
colors = require 'colors/safe'
errorMessages = require './error_messages'


class SummaryFormatter

  # stream - writable stream to send output
  constructor: ({@minimal, @stream}) ->


  # Prints the result to its stream
  print: ({fixes = {}, results}) ->
    for type, modules of results
      if @minimal
        modules = _.filter modules, ({error, errorIgnored}) -> error and not errorIgnored
      continue if modules.length is 0
      @write "#{type}:"
      for module in modules
        fixed = _.includes fixes[type], module.name
        @write @moduleOutput(module, fixed), 1
      @write ''
    @write @summaryOutput(results) unless @minimal and @errorCount(results) is 0


  moduleOutput: ({error, errorIgnored, files, name, scripts}, fixed) ->
    if error
      message = errorMessages[error]
      if errorIgnored
        colors.yellow "- #{name} (#{message} - ignored)"
      else
        header = if fixed
          colors.magenta("✖ #{name} (#{message} - fixed)")
        else
          colors.red("✖ #{name} (#{message})")
        header + colors.gray(@errorSuffix {files, scripts})
    else
      "#{colors.green '✓'} #{name}"


  indent: (str, count) ->
    prefix = ''
    prefix += '  ' for [1..count] if count > 0
    prefix + str


  write: (data, indent = 0) ->
    data = data.split('\n').map((str) => @indent str, indent).join('\n') + '\n'
    @stream.write data, 'utf8'


  errorCount: (results) ->
    count = 0
    for title, modules of results
      for {error, errorIgnored} in modules when error and not errorIgnored
        count += 1
    count


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


module.exports = SummaryFormatter
