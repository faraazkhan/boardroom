Sockets = require './../sockets'
ApplicationController = require './application'
Board = require './../models/board'
Card = require './../models/card'
util = require 'util'

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
          user: request.session
          boards: boards
          countsByBoard: countsByBoard

  show: (request, response) =>
    id = request.params.id
    Board.findById id, (error, board) =>
      #return @throw500 response, error if error?
      return @throw404 response unless board?

      Card.findByBoardName board.name, (error, cards) =>
        board =
          name: board.name
          cards: cards
          groups: board?.groups || {}
          users: Sockets.boards[board.name] || {}
          title: board.name
          user_id: request.session.user_id
        response.render 'board',
          board: board
          user: request.session

  destroy: (request, response) =>
    Board.findById request.params.id, (error, board) ->
      board.destroy (error) ->
        response.redirect '/boards'

module.exports = BoardsController
