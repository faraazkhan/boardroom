require 'fibrous'
Sockets = require './../sockets'
ApplicationController = require './application'
Board = require './../models/board'
Group = require './../models/group'
Card = require './../models/card'
util = require 'util'

class BoardsController extends ApplicationController
  create: (request, response) =>
    
    board = new Board request.body
    board.creator = request.session.user_id
    board.sync.save()
    
    group = new Group { boardId: board.id, x: 500, y: 250, z: 1 }
    group.sync.save()

    authors = ['@carbonfive']
    text = 'Welcome to your virtual whiteboard!\n\n1. Invite others to participate by copying the url or clicking on the link icon in the top right corner.\n\n2. Double click anywhere on the board to create a new note.\n\n3. Drag notes onto one another to create a group.\n\n'
    card = new Card { groupId: group.id, creator: request.session.user_id, authors: authors, text: text }
    card.sync.save()
    
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
    board.sync.remove() if board?
    response.redirect '/'

module.exports = BoardsController
