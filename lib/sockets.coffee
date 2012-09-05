sockets = require 'socket.io'
board   = require './board'
card    = require './card'

io = undefined
boards_channel = undefined
boardNamespaces = undefined

listen = (namespaces, app) ->
  boardNamespaces = namespaces
  io = sockets.listen app
  io.set 'log level', 1

createBoardSession = (boardName) ->
  boards_channel = io
    .of("/channel/boards")
    .on 'connection', (socket) ->
      rebroadcast socket, ['delete']
      socket.on 'delete', (deleteBoard) ->
        board.deleteBoard deleteBoard.board_id
        io.of("/boardNamespace/#{deleteBoard.boardName}").emit 'boardDeleted'

  boardMembers = {}
  boardNamespace = io
    .of("/boardNamespace/#{boardName}")
    .on 'connection', (socket) ->
      rebroadcast socket, ['move', 'text', 'color']
      socket.on 'join', (user) ->
        boardMembers[user.user_id] = user
        boardNamespace.emit 'joined', user
        board.findOrCreateBoard boardName, user.user_id, (b) -> socket.emit('title_changed', b.title)

      socket.on 'add', (data) ->
        addCard boardNamespace, data
        board.findBoard boardName, (b) ->
          boards_channel.emit 'card_added', b, data.author

      socket.on 'delete', (data) ->
        deleteCard(boardNamespace,data)
        board.findBoard boardName, (b) ->
          boards_channel.emit 'card_deleted', b, data.author

      socket.on 'move_commit', updateCard
      socket.on 'text_commit', updateCard
      socket.on 'color', updateCard

      socket.on 'updateGroup', (data) ->
        group.updateGroup data.boardName, data._id, data.name, data.cardIds
        socket.broadcast.emit 'createdOrUpdatedGroup', data

      socket.on 'removeCard', (data) ->
        if data.cardIds.length == 0
          group.removeGroup data.boardName, data._id
        else
          group.updateGroup data.boardName, data._id, data.cardIds
        socket.broadcast.emit 'removedCard', data

      socket.on 'createGroup', (data) ->
        group.createGroup data.boardName, "New Stack", data.cardIds, (group) ->
          socket.broadcast.emit 'createdOrUpdatedGroup', group
          socket.emit 'createdOrUpdatedGroup', group

      socket.on 'title_changed', (data) ->
        board.updateBoard boardName, { title: data.title }
        socket.broadcast.emit 'title_changed', data.title
        board.findBoard boardName, (b) ->
          boards_channel.emit('board_changed', b)

  boardNamespaces[boardName] = boardMembers

rebroadcast = (socket, events) ->
  events.forEach (event) ->
    socket.on event, (data) -> socket.broadcast.emit( event, data )

deleteCard = (boardNamespace, existingCard) ->
  card.removeCard { _id: existingCard._id }, ->
    boardNamespace.emit 'delete', card

addCard = (boardNamespace, attributes) ->
  card.saveCard attributes, ( saved ) ->
    boardNamespace.emit 'add', saved

updateCard = (existingCard) ->
  card.updateCard existingCard
  board.findBoard existingCard.board_name, (b) ->
    boards_channel.emit 'user_activity', b, existingCard.author, 'Did something'

module.exports = {
  createBoardSession
  listen
}
