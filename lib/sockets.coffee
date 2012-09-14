sockets = require 'socket.io'
Board = require './models/board'
Card = require './models/card'

class Sockets
  @boardNamespaces: {}

  @findOrCreateByBoardName: (boardName) ->
    unless @boardNamespaces[boardName]
      @createBoardSession boardName

  @createBoardSession: (boardName) ->
    @boardsChannel = @io
      .of('/channel/boards')
      .on 'connection', (socket) =>
        @rebroadcast socket, ['delete']
        socket.on 'delete', (data) =>
          Board.findById data._id, (error, board) =>
            board.destroy (error) =>
              @io
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
          Board.findByName boardName, (error, board) ->
            socket.emit 'title_changed', board.title

        socket.on 'add', (data) =>
          card = new Card data
          card.authors = []
          card.save (error) =>
            throw error if error
            boardNamespace.emit 'add', card
            # /boards functionality
            Board.findByName boardName, (error, board) =>
              @boardsChannel.emit 'card_added', board, data.author

        socket.on 'delete', (data) =>
          Card.findById data._id, (error, card) =>
            throw error if error
            card.remove (error) =>
              throw error if error
              boardNamespace.emit 'delete', card
              # /boards functionality
              Board.findByName boardName, (error, board) =>
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
          Board.findByName boardName, (error, board) =>
            board.title = data.title
            board.save (error) =>
              boardNamespace.emit 'title_changed', board.title
              # /boards functionality
              @boardsChannel.emit 'board_changed', board

        socket.on 'createGroup', (data) ->
          Board.findByName data.boardName, (error, board) ->
            attributes =
              name: 'New Stack'
              cardIds: data.cardIds
            board.addGroup attributes, (group) ->
              socket.broadcast.emit 'createdOrUpdatedGroup', group
              socket.emit 'createdOrUpdatedGroup', group

        socket.on 'updateGroup', (data) ->
          group.updateGroup data.boardName, data._id, data.name, data.cardIds
          socket.broadcast.emit 'createdOrUpdatedGroup', data

    @boardNamespaces[boardName] = @boardMembers

  @rebroadcast: (socket, events) ->
    events.forEach (event) ->
      socket.on event, (data) ->
        socket.broadcast.emit(event, data)

  @updateCard: (attributes) =>
    Card.findById attributes._id, (error, card) =>
      throw error if error
      card.updateAttributes attributes, =>
        Board.findByName card.boardName, (error, board) =>
          # /boards functionality
          @boardsChannel.emit 'user_activity', board, card.author, 'Did something'

  @start: (app) ->
    @boardsChannel = undefined
    @io = sockets.listen app
    @io.set 'log level', 1

module.exports = Sockets
