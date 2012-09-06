sockets     = require './../sockets'
db          = require './../models/db'
board       = require './../models/board'
card        = require './../models/card'
application = require './application'

class BoardsController extends application.ApplicationController
  index: (request, response) =>
    board.Board.findBoards (boards) =>
      card.Card.countsByBoard (countsByBoard) =>
        response.render 'boards',
          user: @userInfo(request)
          boards: boards
          countsByBoard: countsByBoard

  show: (request, response) =>
    response.render 'board', user: @userInfo(request)

  info: (request, response) =>
    boardName = request.params.board
    card.Card.findByBoardName boardName, (cards) ->
      board.Board.findBoardAllowEmpty boardName, (board) ->
        response.send
          name: boardName
          cards: cards
          groups: board && board.groups || {}
          users: sockets.Server.boardNamespaces[boardName] || {}
          title: boardName
          user_id: request.session.user_id

module.exports = { BoardsController }
