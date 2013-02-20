clc = require 'cli-color'

class Logger

  constructor: ->
    @level = 1
    @eventHistory = {}

  setLevel: (level) =>
    @level = ['error', 'warn', 'info', 'debug'].indexOf(level)
    @level = 1 if @level == -1

  rememberEvent: (boardId, event, message) =>
    unless message.author?
      @warn -> "Cannot remember event with no author: #{event}"
      return

    events = @eventHistory[boardId] || []
    events.push [event, message]
    events.splice 0, (events.length - 10)
    @eventHistory[boardId] = events

  error: (msg) =>
    @log 'ERROR', msg

  warn: (msg) =>
    @log 'WARN', msg if @level >= 1

  info: (msg) =>
    @log 'INFO', msg if @level >= 2

  debug: (msg) =>
    @log 'DEBUG', msg if @level >= 3

  log: (level, msg) =>
    unless typeof msg == 'function'
      console.log 'LOGGING ERROR: You must pass a function to the logger'
      console.log '  Example: @logger.warn -> "cannot find object #{foo}"'
      console.log "  Your message is: '#{msg}'"
      return

    d = new Date()
    level = if level.length == 4 then "#{level} " else level
    preamble = "[#{@timestamp()} #{@colorize(level) level}]"
    console.log "#{preamble}  #{msg()}"

  logClient: (user, boardId, level, msg) =>
    clientMsg = -> clc.xterm(110)("CLIENT [#{user}]") + "  " + msg
    @log level, clientMsg
    @logBoardHistory boardId if level == 'ERROR'

  logValidationErrors: (errors) =>
    for property, error of errors
      @error -> error.message

  logBoardHistory: (boardId) =>
    events = @eventHistory[boardId] || []
    console.log ""
    console.log "----- last #{events.length} events for board #{boardId} -----"
    for [event, message] in events
      console.log "  #{event} : #{JSON.stringify(message)}"
    console.log ""

  timestamp: =>
    d = new Date()
    pad = (i) -> if i < 10 then "0#{i}" else "#{i}"
    date = "#{d.getFullYear()}-#{pad d.getMonth()}-#{pad d.getDate()}"
    time = "#{pad d.getHours()}:#{pad d.getMinutes()}:#{pad d.getSeconds()}"
    #clc.xterm(228) "#{date} #{time}"
    "#{date} #{time}"

  colors:
    DEBUG: 255
    INFO: 40
    WARN: 208
    ERROR: 196

  colorize: (level) =>
    color = @colors[level.trim()] || 255
    clc.xterm(color)

module.exports = new Logger()
