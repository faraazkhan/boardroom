require 'fibrous'
Sockets = require './../sockets'
ApplicationController = require './application'
Board = require './../models/board'
Card = require './../models/card'
Path = require './../models/path'
util = require 'util'

class BoardsController extends ApplicationController
  create: (request, response) =>
    board = new Board request.body
    board.creator = request.session.user_id
    board.sync.save()
    response.redirect "/boards/#{board.id}"

  show: (request, response) =>
    try
      id = request.params.id
      board = Board.sync.findById id
      return @throw404 response unless board?
      cards = Card.sync.findByBoardId board.id
      paths = Path.sync.findByBoardId board.id
      board =
        _id: board.id
        name: board.name
        cards: cards
        paths: paths
        users: Sockets.boards[board.name] || {}
        user_id: request.session.user_id
      response.render 'board',
        board: board
        user: request.session
    catch error
      return @throw500 response, error

  destroy: (request, response) =>
    board = Board.sync.findById request.params.id
    board.sync.destroy()
    response.redirect '/'

module.exports = BoardsController
