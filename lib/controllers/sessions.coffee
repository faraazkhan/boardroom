ApplicationController = require './application'
BoardsController = require '../controllers/boards'
Board = require '../models/board'

class SessionsController extends ApplicationController
  new: (request, response) ->
    response.render 'login', {layout: false}

  create: (request, response) ->
    redirect_url = request.session?.post_auth_url ? '/'
    user_id = request.body.user_id
    request.session = user_id: user_id

    createdBoards      = (Board.sync.createdBy user_id) || []
    collaboratedBoards = (Board.sync.collaboratedBy user_id) || []

    if (createdBoards + collaboratedBoards).length > 0
      response.redirect redirect_url
    else
      boardsController = new BoardsController
      board = boardsController.build "#{user_id}'s board", user_id
      response.redirect "/boards/#{board.id}"

  destroy: (request, response) ->
    request.session = {}
    response.redirect '/'

module.exports = SessionsController
