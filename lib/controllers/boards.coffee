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
    text = 'Hi!\n\n1. This is a note. Double click anywhere on the board to create a new note.\n\n2. Now drag your new note on top of me to create a group.\n\n3. Remove notes from groups by dragging them out.\n\n4. Try typing "I wish" into a new note. Neat!\n\n5. Now try typing "I like" into a new note. Woohoo!'
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
