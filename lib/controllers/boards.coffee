db          = require './../db'
sockets     = require './../sockets'
board       = require './../board'
card        = require './../card'
application = require './application'

class BoardsController extends application.ApplicationController
  constructor: (@socket) ->

  index: (request, response) =>
    that = @
    board.findBoards {deleted:{$ne:true}}, db.arrayReducer (boards) ->
      board.findBoardCardCounts (boardCounts) ->
        boardCountsByName = boardCounts.reduce((o,item) ->
          o[item.boardName]=item.count
          return o
        ,{})
        response.render "boards",
          user: that.userInfo(request)
          boards: boards
          boardCounts: boardCountsByName

  show: (request, response) =>
    if !sockets.Server.boardNamespaces[request.params.board]
      @socket.createBoardSession request.params.board
    response.render "board", { user: @userInfo(request) }

  info: (request, response) =>
    that = @
    boardName = request.params.board
    card.findCards { boardName:boardName, deleted:{$ne:true} }, db.arrayReducer (cards) ->
      board.findBoardAllowEmpty boardName, (board) ->
        response.send
          name: boardName
          cards: cards
          groups: board && board.groups || {}
          users: sockets.Server.boardNamespaces[boardName] || {}
          user_id: request.session.user_id
          title: boardName

module.exports = { BoardsController }
