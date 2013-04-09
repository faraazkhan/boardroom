sockets = require 'socket.io'
logger = require './logger'
Handler = require './handler'
Board = require '../models/board'
Group = require '../models/group'
Card = require '../models/card'

class Sockets
  @boards: {}

  @middleware: (request, _, next) =>
    @findOrCreateByBoardId request.params.id
    next()

  @findOrCreateByBoardId: (boardId) ->
    unless @boards[boardId]
      @createBoard boardId

  @createBoard: (boardId) ->
    handlers =
      board: Board
      group: Group
      card : Card
    @users = {}

    boardNamespace = @io
      .of("/boards/#{boardId}")
      .on 'connection', (socket) =>
        for name, modelClass of handlers
          handler = new Handler modelClass, name, boardId, socket
          handler.registerAll()

        socket.on 'join', (user) =>
          @users[user.user_id] = user
          boardNamespace.emit 'join', user
          logger.info -> "#{user.user_id} has joined board #{boardId}"

        socket.on 'log', ({user, boardId, level, msg}) =>
          logger.logClient user, boardId, level, msg

        socket.on 'marker', ({user, boardId}) =>
          logger.rememberEvent boardId, 'marker', { author: user }

    @boards[boardId] = @users

  @start: (server, opts) ->
    @io = sockets.listen server
    @io.set 'log level', 1

    if opts?.cluster is true
      RedisStore = require 'socket.io/lib/stores/redis'
      redis      = require 'socket.io/node_modules/redis'

      @io.set 'store', new RedisStore
        redisPub: redis.createClient()
        redisSub: redis.createClient()
        redisClient: redis.createClient()

module.exports = Sockets
