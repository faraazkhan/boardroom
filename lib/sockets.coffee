sockets = require 'socket.io'
board   = require './models/board'
card    = require './models/card'
util = require 'util'

Board   = board.Board
Card    = card.Card

class Server
  @boardNamespaces: {}

  @findOrCreateByBoardName: (boardName) ->
    unless @boardNamespaces[boardName]
      @createBoardSession boardName

  @createBoardSession: (boardName) ->
    @boardsChannel = @io
      .of('/channel/boards')
      .on 'connection', (socket) =>
        @rebroadcast socket, ['delete']
        socket.on 'delete', (data) ->
          Board.findByName data.boardName, (board) ->
            board.destroy (error) ->
              io
                .of("/boardNamespace/#{data.boardName}")
                .emit 'boardDeleted'

    @boardMembers = {}

    boardNamespace = @io
      .of("/boardNamespace/#{boardName}")
      .on 'connection', (socket) =>
        @rebroadcast socket, ['move', 'text', 'color']
        socket.on 'join', (user) =>
          @boardMembers[user.user_id] = user
          boardNamespace.emit 'joined', user
          Board.findOrCreateByNameAndCreatorId boardName, user.user_id, (board) ->
            socket.emit 'title_changed', board.title

        socket.on 'add', (data) =>
          @addCard boardNamespace, data
          Board.findByName boardName, (board) =>
            @boardsChannel.emit 'card_added', board, data.author

        socket.on 'delete', (data) =>
          @deleteCard boardNamespace, data
          Board.findByName boardName, (board) =>
            @boardsChannel.emit 'card_deleted', board, data.author

        socket.on 'move_commit', @updateCard
        socket.on 'text_commit', @updateCard
        socket.on 'color', @updateCard

        socket.on 'removeCard', (data) ->
          if data.cardIds.length is 0
            group.removeGroup data.boardName, data._id
          else
            group.updateGroup data.boardName, data._id, data.cardIds
          socket.broadcast.emit 'removedCard', data

        socket.on 'title_changed', (data) =>
          Board.findByName boardName, (board) =>
            board.title = attributes.title
            board.save (error) =>
              socket.broadcast.emit 'title_changed', board.title
              @boardsChannel.emit 'board_changed', board

        socket.on 'createGroup', (data) ->
          Board.findByName data.boardName, (board) ->
            util.log util.inspect board
            attributes =
              name: 'New Stack'
              cardIds: data.cardIds
            board.addGroup attributes, (group) ->
              socket.broadcast.emit 'createdOrUpdatedGroup', group
              socket.emit 'createdOrUpdatedGroup', group

        socket.on 'updateGroup', (data) ->
          util.log 'updateGroup'
          group.updateGroup data.boardName, data._id, data.name, data.cardIds
          socket.broadcast.emit 'createdOrUpdatedGroup', data

    @boardNamespaces[boardName] = @boardMembers

  @rebroadcast: (socket, events) ->
    events.forEach (event) ->
      socket.on event, (data) ->
        socket.broadcast.emit(event, data)

  @addCard: (boardNamespace, attributes) ->
    card = new Card attributes
    card.authors = []
    card.save (error) ->
      boardNamespace.emit 'add', card

  @updateCard: (attributes) =>
    Card.findById attributes._id, (error, card) ->
      card.updateAttributes attributes, ->
        Board.findByName card.boardName, (board) =>
          @boardsChannel.emit 'user_activity', board, card.author, 'Did something'

  @deleteCard: (boardNamespace, existingCard) ->
    Card.findById existingCard._id, (error, card) ->
      card.remove (error) ->
        boardNamespace.emit 'delete', card

  @start: (app) ->
    @boardsChannel = undefined
    @io = sockets.listen app
    @io.set 'log level', 1

module.exports = { Server }
