sockets = require 'socket.io'
board   = require './models/board'
card    = require './models/card'
util = require 'util'

Board   = board.Board
Card    = card.Card

class Sockets
  @boardNamespaces: {}

  @findOrCreateByBoardName: (boardName) ->
    unless @boardNamespaces[boardName]
      @createBoardSession boardName

  @createBoardSession: (boardName) ->
    @boardsChannel = @io
      .of('/channel/boards')
      .on 'connection', (socket) =>
        console.log 'connect'
        @rebroadcast socket, ['delete']
        socket.on 'delete', (data) =>
          console.log 'delete bitch'
          Board.findByName data.boardName, (board) =>
            console.log board
            board.destroy (error) =>
              console.log error
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
          Board.findByName boardName, (board) ->
            socket.emit 'title_changed', board.title

        socket.on 'add', (data) =>
          card = new Card data
          card.authors = []
          card.save (error) =>
            throw error if error
            boardNamespace.emit 'add', card
            # /boards functionality
            Board.findByName boardName, (board) =>
              @boardsChannel.emit 'card_added', board, data.author

        socket.on 'delete', (data) =>
          Card.findById data._id, (error, card) =>
            throw error if error
            card.remove (error) =>
              throw error if error
              boardNamespace.emit 'delete', card
              # /boards functionality
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
            board.title = data.title
            board.save (error) =>
              socket.broadcast.emit 'title_changed', board.title
              # /boards functionality
              @boardsChannel.emit 'board_changed', board

        socket.on 'createGroup', (data) ->
          Board.findByName data.boardName, (board) ->
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
        Board.findByName card.boardName, (board) =>
          # /boards functionality
          @boardsChannel.emit 'user_activity', board, card.author, 'Did something'

  @start: (app) ->
    @boardsChannel = undefined
    @io = sockets.listen app
    #@io.set 'log level', 1

module.exports = { Sockets }
