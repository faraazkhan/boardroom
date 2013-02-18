class boardroom.utils.Logger

  constructor: ->
    @level = 1

  setLevel: (level) =>
    @level = ['error', 'warn', 'info', 'debug'].indexOf(level)
    @level = 1 if @level == -1

  error: (msg) =>
    @log 'ERROR', msg
    @serverLog 'ERROR', msg

  warn: (msg) =>
    @log 'WARN ', msg if @level >= 1
    @serverLog 'WARN', msg

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
      console.log msg

  serverLog: (level, msg) =>
    @socket.emit 'log', { user: @user.get('user_id'), level, msg }

boardroom.utils.Logger.instance = new boardroom.utils.Logger()
