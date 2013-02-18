sockets = require 'socket.io'
logger = require './utils/logger'
CardHandler = require './handlers/card_handler'
GroupHandler = require './handlers/group_handler'
BoardHandler = require './handlers/board_handler'

class Sockets
  @boards: {}

  @findOrCreateByBoardId: (boardId) ->
    unless @boards[boardId]
      @createBoard boardId

  @createBoard: (boardId) ->
    handlers = [ CardHandler, GroupHandler, BoardHandler ]
    @users = {}

    boardNamespace = @io
      .of("/boards/#{boardId}")
      .on 'connection', (socket) =>
        for Handler in handlers
          do (Handler) ->
            handler = new Handler()
            handler.socket = socket
            handler.registerAll()

        socket.on 'join', (user) =>
          @users[user.user_id] = user
          boardNamespace.emit 'join', user

        socket.on 'log', ({user, level, msg}) =>
          logger.logClient user, level, msg

    @boards[boardId] = @users

  @start: (app) ->
    @io = sockets.listen app
    @io.set 'log level', 1

module.exports = Sockets
