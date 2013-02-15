class boardroom.utils.Logger

  constructor: ->
    @level = ['error', 'warn', 'info', 'debug'].indexOf('debug') || 3

  error: (msg) =>
    @log 'ERROR', msg

  warn: (msg) =>
    @log 'WARN ', msg if @level >= 1

  info: (msg) =>
    @log 'INFO ', msg if @level >= 2

  debug: (msg) =>
    @log 'DEBUG', msg if @level >= 3

  log: (level, msg) =>
    d = new Date()
    ts = "#{d.getFullYear()}-#{d.getMonth()}-#{d.getDate()} #{d.getHours()}:#{d.getMinutes()}:#{d.getSeconds()}"
    if typeof msg == 'string'
      console.log "[#{ts} #{level}]  #{msg}"
    else
      console.log "[#{ts} #{level}]"
      console.log msg
