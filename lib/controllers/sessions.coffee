ApplicationController = require './application'
BoardsController = require '../controllers/boards'
Board = require '../models/board'
async = require 'async'

class SessionsController extends ApplicationController
  new: (request, response) ->
    response.render 'login', {layout: false}

  create: (request, response) ->
    redirect_url = request.session?.post_auth_url ? '/'
    user_id = request.body.user_id
    request.session = user_id: user_id

    loadCreatedBoards = (done) ->
      Board.createdBy user_id, (err, createdBoards) ->
        throw err if err
        done(null, createdBoards || [])

    loadCollaboratedBoards = (done) ->
      Board.collaboratedBy user_id, (err, collaboratedBoards) ->
        throw err if err
        done(null, collaboratedBoards || [])

    onLoadComplete = (err, boards) ->
      if (boards.created.length + boards.collaborated.length > 0) or redirect_url != '/'
        response.redirect redirect_url
      else
        boardsController = new BoardsController
        boardsController.build "#{user_id}'s board", user_id, (board) ->
          response.redirect "/boards/#{board.id}"

    async.parallel
      "created" : loadCreatedBoards
      "collaborated" : loadCollaboratedBoards
    , onLoadComplete

  destroy: (request, response) ->
    request.session = {}
    response.redirect '/'

module.exports = SessionsController
