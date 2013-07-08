Sockets = require '../services/sockets'
ApplicationController = require './application'
Board = require '../models/board'
Group = require '../models/group'
Card = require '../models/card'
util = require 'util'
async = require 'async'

class BoardsController extends ApplicationController
  create: (request, response) =>
    @build request.body.name, request.user._id, (board) ->
      response.redirect "/boards/#{board.id}"

  show: (request, response) =>
    userIdentity = request.user.activeIdentity
    loglevel = request.param 'loglevel'
    try
      id = request.params.id
      socketInfo = Sockets.socketInfo id
      namespace = (socketInfo ? {}).namespace
      Board.findById id, (err, boardModel) =>
        throw err if err
        return @throw404 response unless boardModel?
        board = boardModel.toObject getters: true
        board._id = board.id
        board.displayName = userIdentity.displayName
        board.userIdentitySet ?= {}
        board.userIdentitySet[userIdentity.userId] = userIdentity
        board.currentUserId = userIdentity.userId
        response.render 'board', { board, userIdentity, loglevel, namespace }
    catch error
      return @throw500 response, error

  destroy: (request, response) =>
    redirect = () ->
      response.redirect "/"

    Board.findById request.params.id, (err, board) ->
      throw err if err
      if board
        board.remove (err) ->
          throw err if err
          redirect()
      else
        redirect()

  build: (name, creator, done) =>
    createBoard = (next) ->
      board = new Board {name, creator }
      board.save (err, board) ->
        throw err if err
        next(null, board)

    createGroup = (board, next) ->
      group = new Group { boardId: board.id, x: 500, y: 250, z: 1 }
      group.save (err, group) ->
        throw err if err
        next(null, board, group)

    createCard = (board, group, next) ->
      # TODO Set the first author to Carbon Five
      groupId = group.id
      authors = [ creator ]
      text = 'Welcome to your virtual whiteboard!\n\n1. Invite others to participate by copying the url or clicking on the link icon in the top right corner.\n\n2. Double click anywhere on the board to create a new note.\n\n3. Drag notes onto one another to create a group.\n\n'
      card = new Card { groupId, creator, authors, text }
      card.save (err, card) ->
        throw err if err
        next(null, board)

    async.waterfall [createBoard, createGroup, createCard], (err, board) ->
      done(board)

module.exports = BoardsController
