require 'fibrous'
Sockets = require '../services/sockets'
ApplicationController = require './application'
Board = require '../models/board'
Group = require '../models/group'
Card = require '../models/card'
util = require 'util'

class BoardsController extends ApplicationController
  create: (request, response) =>
    @build request.body.name, request.session.user_id, (err, board)->
      response.redirect "/boards/#{board.id}"

  show: (request, response) =>
    try
      id = request.params.id
      Board.findById id, (error, board)->
        return @throw404 response unless board?
        board = board.toObject getters: true
        board._id = board.id
        board.users = Sockets.boards[board.name] || {}
        board.user_id = request.session.user_id
        response.render 'board',
          board: board
          user: request.session
          loglevel: request.param 'loglevel'
    catch error
      return @throw500 response, error

  destroy: (request, response) =>
    Board.findById request.params.id, (err, board)->
      if board?
        board.remove (err, result)->
          response.redirect '/'
      else 
        response.redirect '/'

  build: (name, creator, callback) =>
    board = new Board name: name, creator: creator
    board.save (error, savedBoard) ->
      group = new Group { boardId: board.id, x: 500, y: 250, z: 1 }
      group.save (error, savedGroup)->
        authors = ['@carbonfive']
        text = 'Welcome to your virtual whiteboard!\n\n1. Invite others to participate by copying the url or clicking on the link icon in the top right corner.\n\n2. Double click anywhere on the board to create a new note.\n\n3. Drag notes onto one another to create a group.\n\n'
        card = new Card { groupId: group.id, creator: creator, authors: authors, text: text }
        card.save (error, savedCard)->
           callback null, savedBoard

module.exports = BoardsController
