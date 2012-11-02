require 'fibrous'
Sockets = require './../sockets'
ApplicationController = require './application'
Board = require './../models/board'
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
      board = board.toObject getters: true
      board._id = board.id
      board.users = Sockets.boards[board.name] || {}
      board.user_id = request.session.user_id
      response.render 'board',
        board: board
        user: request.session
    catch error
      return @throw500 response, error

  destroy: (request, response) =>
    board = Board.sync.findById request.params.id
    board.sync.remove()
    response.redirect '/'

module.exports = BoardsController
