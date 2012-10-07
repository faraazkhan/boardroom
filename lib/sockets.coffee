sockets = require 'socket.io'
CardHandler = require './handlers/card_handler'
BoardHandler = require './handlers/board_handler'

class Sockets
  @boards: {}

  @findOrCreateByBoardId: (boardId) ->
    unless @boards[boardId]
      @createBoard boardId

  @createBoard: (boardId) ->
    handlers = [ CardHandler, BoardHandler ]
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
          boardNamespace.emit 'joined', user

    @boards[boardId] = @users

  @start: (app) ->
    @io = sockets.listen app
    @io.set 'log level', 1

module.exports = Sockets
