sockets = require 'socket.io'
logger = require './logger'
Handler = require './handler'
Board = require '../models/board'
Group = require '../models/group'
Card = require '../models/card'

class Sockets
  @info: {}

  @middleware: (request, _, next) =>
    @createSocket request.params.id
    next()

  @createSocket: (boardId) ->
    return if @socketInfo boardId

    handlers =
      board: Board
      group: Group
      card : Card

    env = process.env.NODE_ENV ? 'development'
    namespace = "/#{env}/boards/#{boardId}"
    @info[boardId] = { namespace }

    boardNamespace = @io
      .of(namespace)
      .on 'connection', (socket) =>
        remoteAddress = socket.handshake.headers['x-forwarded-for'] || socket.handshake.address.address
        logger.debug -> "Socket connection from #{remoteAddress} (pid #{process.pid})"

        for name, modelClass of handlers
          handler = new Handler modelClass, name, boardId, socket
          handler.registerAll()

        socket.on 'disconnect', =>
          logger.info -> "#{socket.boardroomUser?.displayName} has disconnected"

        socket.on 'join', (user) =>
          socket.boardroomUser = user
          boardNamespace.emit 'join', { userId: user.userId, @users }
          logger.info -> "#{user.displayName} has joined board #{boardId} (pid: #{process.pid})"

        socket.on 'log', ({user, boardId, level, msg}) =>
          logger.logClient user, boardId, level, msg

        socket.on 'marker', ({user, boardId}) =>
          logger.rememberEvent boardId, 'marker', { author: user }

  @socketInfo: (boardId) ->
    @info[boardId]

  @start: (server) ->
    RedisStore = require 'socket.io/lib/stores/redis'
    redis      = require 'socket.io/node_modules/redis'

    store = new RedisStore
      redisPub: redis.createClient()
      redisSub: redis.createClient()
      redisClient: redis.createClient()

    @io = sockets.listen server
    @io.set 'log level', 1
    @io.set 'store', store

module.exports = Sockets
