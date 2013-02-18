clc = require 'cli-color'

class Logger

  constructor: ->
    @level = 1

  setLevel: (level) =>
    @level = ['error', 'warn', 'info', 'debug'].indexOf(level)
    @level = 1 if @level == -1

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
      return

    d = new Date()
    level = if level.length == 4 then "#{level} " else level
    preamble = "[#{@timestamp()} #{@colorize(level) level}]"
    console.log "#{preamble}  #{msg()}"

  logClient: (user, level, msg) =>
    clientMsg = -> clc.xterm(110)("CLIENT [#{user}]") + "  " + msg
    @log level, clientMsg

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
