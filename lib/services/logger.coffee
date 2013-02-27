clc = require 'cli-color'

class Logger

  constructor: ->
    @level = 1
    @eventHistory = {}

  setLevel: (level) =>
    @level = ['error', 'warn', 'info', 'debug'].indexOf(level)
    @level = 1 if @level == -1

  rememberEvent: (boardId, event, message) =>
    date = new Date()
    events = @eventHistory[boardId] || []
    events.push { date, event, message }
    events.splice 0, (events.length - 50)
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
      @warn -> '***** Please pass functions to the logger *****'
      msg = -> msg

    d = new Date()
    level = if level.length == 4 then "#{level} " else level
    preamble = "[#{@datetimestamp(d)} #{@colorize(level) level}]"
    console.log "#{preamble}  #{msg()}"

  logClient: (user, boardId, level, msg) =>
    clientMsg = -> clc.xterm(110)("CLIENT [#{user}]") + "  " + msg
    @log level, clientMsg
    @logBoardHistory user, boardId if level == 'ERROR'

  logValidationErrors: (errors) =>
    for property, error of errors
      @error -> error.message

  logBoardHistory: (user, boardId) =>
    events = @getBoardHistory user, boardId
    console.log "----- last #{events.length} events for board #{boardId} -----"
    for {date, event, message} in events
      author = message.author
      delete message.boardId
      delete message.cid
      delete message.author
      console.log "  #{@timestamp(date)} (#{event} - #{author}) : #{JSON.stringify(message)}"
    console.log ""

  getBoardHistory: (user, boardId) =>
    events = @eventHistory[boardId] || []
    for {date, event, message}, i in events
      last = i if message.author == user and event == 'marker'
    first = last - 9
    first = 0 if first < 0
    events.slice first, last + 1

  datetimestamp: (d) =>
    date = "#{d.getFullYear()}-#{@pad d.getMonth(), 2}-#{@pad d.getDate(), 2}"
    time = "#{@pad d.getHours(), 2}:#{@pad d.getMinutes(), 2}:#{@pad d.getSeconds(), 2}"
    #clc.xterm(228) "#{date} #{time}"
    "#{date} #{time}"

  timestamp: (d) =>
    "#{@pad d.getHours(), 2}:#{@pad d.getMinutes(), 2}:#{@pad d.getSeconds(), 2}.#{@pad d.getMilliseconds(), 3}"

  pad: (num, digits) ->
    s = "#{num}"
    s = "0#{num}" while s.length < digits
    s

  colors:
    DEBUG: 255
    INFO: 40
    WARN: 208
    ERROR: 196

  colorize: (level) =>
    color = @colors[level.trim()] || 255
    clc.xterm(color)

module.exports = new Logger()
