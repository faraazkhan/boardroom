{ Sockets }               = require './../sockets'
{ ApplicationController } = require './application'
{ Board }                 = require './../models/board'
{ Card }                  = require './../models/card'

class BoardsController extends ApplicationController
  create: (request, response) =>
    board = new Board request.body
    board.name = board.title
    board.creator_id = request.session.user_id
    board.save (error) ->
      response.redirect "/boards/#{board.name}"

  index: (request, response) =>
    Board.all (boards) =>
      Card.countsByBoard (countsByBoard) =>
        response.render 'boards',
          user: @userInfo(request)
          boards: boards
          countsByBoard: countsByBoard

  show: (request, response) =>
    boardName = request.params.board
    Card.findByBoardName boardName, (cards) =>
      Board.findByName boardName, (board) =>
        board =
          name: boardName
          cards: cards
          groups: (board && board.groups) || {}
          users: Sockets.boardNamespaces[boardName] || {}
          title: boardName
          user_id: request.session.user_id
        response.render 'board',
          user: @userInfo(request)
          boardAsJson: JSON.stringify(board)

module.exports = { BoardsController }
