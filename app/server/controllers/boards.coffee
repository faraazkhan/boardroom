{ Sockets }               = require './../sockets'
{ ApplicationController } = require './application'
{ Board }                 = require './../models/board'
{ Card }                  = require './../models/card'

class BoardsController extends ApplicationController
  index: (request, response) =>
    Board.findBoards (boards) =>
      Card.countsByBoard (countsByBoard) =>
        response.render 'boards',
          user: @userInfo(request)
          boards: boards
          countsByBoard: countsByBoard

  show: (request, response) =>
    response.render 'board', user: @userInfo(request)

  info: (request, response) =>
    boardName = request.params.board
    Card.findByBoardName boardName, (cards) ->
      Board.findBoardAllowEmpty boardName, (board) ->
        response.send
          name: boardName
          cards: cards
          groups: board && board.groups || {}
          users: Sockets.boardNamespaces[boardName] || {}
          title: boardName
          user_id: request.session.user_id

module.exports = { BoardsController }
