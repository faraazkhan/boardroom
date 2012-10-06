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
            handler.namespace = boardNamespace
            handler.socket = socket
            handler.registerAll()



        @rebroadcast socket, ['move', 'text', 'color']
        socket.on 'join', (user) =>
          @users[user.user_id] = user
          boardNamespace.emit 'joined', user

        socket.on 'add', (data) =>
          card = new Card data
          card.save (error) =>
            throw error if error?
            boardNamespace.emit 'add', card

        socket.on 'move_commit', @updateCard
        socket.on 'text_commit', @updateCard
        socket.on 'color', @updateCard

        socket.on 'name_changed', (data) =>
          Board.findById boardId, (error, board) =>
            board.name = data.name
            board.save (error) =>
              boardNamespace.emit 'name_changed', board.name

    @boards[boardId] = @users

  @rebroadcast: (socket, events) ->
    events.forEach (event) ->
      socket.on event, (data) ->
        socket.broadcast.emit(event, data)

  @updateCard: (attributes) =>
    Card.findById attributes._id, (error, card) =>
      throw error if error?
      card.updateAttributes attributes, ->

  @start: (app) ->
    @io = sockets.listen app
    @io.set 'log level', 1

module.exports = Sockets
