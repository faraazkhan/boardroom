sockets = require 'socket.io'
Board = require './models/board'
Card = require './models/card'
CardHandler = require './handlers/card_handler'

class Sockets
  @boards: {}

  @findOrCreateByBoardId: (boardId) ->
    unless @boards[boardId]
      @createBoard boardId

  @createBoard: (boardId) ->
    handlers = [ CardHandler ]
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

        socket.on 'name_changed', (data) =>
          Board.findById boardId, (error, board) =>
            board.name = data.name
            board.save (error) =>
              boardNamespace.emit 'name_changed', board.name

    @boards[boardId] = @users

  @start: (app) ->
    @io = sockets.listen app
    @io.set 'log level', 1

module.exports = Sockets
