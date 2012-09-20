sockets = require 'socket.io'
Board = require './models/board'
Card = require './models/card'
util = require 'util'

class Sockets
  @boards: {}

  @findOrCreateByBoardName: (boardName) ->
    unless @boards[boardName]
      @createBoard boardName

  @createBoard: (boardName) ->
    @users = {}

    boardNamespace = @io
      .of("/boardNamespace/#{boardName}")
      .on 'connection', (socket) =>
        @rebroadcast socket, ['move', 'text', 'color']
        socket.on 'join', (user) =>
          @users[user.user_id] = user
          boardNamespace.emit 'joined', user

        socket.on 'add', (data) =>
          card = new Card data
          card.authors = []
          card.save (error) =>
            throw error if error
            boardNamespace.emit 'add', card

        socket.on 'delete', (data) =>
          Card.findById data._id, (error, card) =>
            throw error if error
            card.remove (error) =>
              throw error if error
              boardNamespace.emit 'delete', card

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

    @boards[boardName] = @users

  @rebroadcast: (socket, events) ->
    events.forEach (event) ->
      socket.on event, (data) ->
        socket.broadcast.emit(event, data)

  @updateCard: (attributes) =>
    Card.findById attributes._id, (error, card) =>
      throw error if error
      card.updateAttributes attributes, ->

  @start: (app) ->
    @io = sockets.listen app
    @io.set 'log level', 1

module.exports = Sockets
