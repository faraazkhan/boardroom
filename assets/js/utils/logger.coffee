class boardroom.utils.Logger

  constructor: ->
    @level = 1
    @board = null

  setLevel: (level) =>
    @level = ['error', 'warn', 'info', 'debug'].indexOf(level)
    @level = 1 if @level == -1

  setBoard: (@board) =>

  error: (msg) =>
    @log 'ERROR', msg
    @serverLog 'ERROR', msg

  warn: (msg) =>
    @log 'WARN', msg if @level >= 1
    @serverLog 'WARN', msg

  info: (msg) =>
    @log 'INFO', msg if @level >= 2
    @serverLog 'INFO', msg if @level >= 2

  debug: (msg) =>
    @log 'DEBUG', msg if @level >= 3

  log: (level, msg) =>
    d = new Date()
    level = if level.length == 4 then "#{level} " else level
    if typeof msg == 'string'
      console.log "[#{@timestamp()} #{level}]  #{msg}"
    else
      console.log msg

  timestamp: =>
    d = new Date()
    pad = (i) -> if i < 10 then "0#{i}" else "#{i}"
    "#{d.getFullYear()}-#{pad d.getMonth()}-#{pad d.getDate()} #{pad d.getHours()}:#{pad d.getMinutes()}:#{pad d.getSeconds()}"

  serverLog: (level, msg) =>
    @socket.emit 'log', { user: @user.get('user_id'), boardId: @board.id, level, msg }

boardroom.utils.Logger.instance = new boardroom.utils.Logger()
