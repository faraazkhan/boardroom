sockets = require 'socket.io'
logger = require './logger'
Handler = require './handler'
Board = require '../models/board'
Group = require '../models/group'
Card = require '../models/card'

class Sockets
  @boards: {}

  @findOrCreateByBoardId: (boardId) ->
    unless @boards[boardId]
      @createBoard boardId

  @createBoard: (boardId) ->
    handlers = [
      new Handler(Board, 'board')
      new Handler(Group, 'group')
      new Handler(Card, 'card')
    ]
    @users = {}

    boardNamespace = @io
      .of("/boards/#{boardId}")
      .on 'connection', (socket) =>
        for handler in handlers
          do (handler) ->
            handler.socket = socket
            handler.registerAll()

        socket.on 'join', (user) =>
          @users[user.user_id] = user
          boardNamespace.emit 'join', user
          logger.info -> "#{user.user_id} has joined board #{boardId}"

        socket.on 'log', ({user, level, msg}) =>
          logger.logClient user, level, msg

    @boards[boardId] = @users

  @start: (app) ->
    @io = sockets.listen app
    @io.set 'log level', 1

module.exports = Sockets
