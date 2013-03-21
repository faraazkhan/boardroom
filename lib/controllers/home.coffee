async = require 'async'

ApplicationController = require './application'
Board = require './../models/board'
BoardsController = require './boards'

class HomeController extends ApplicationController
  index: (request, response) =>
    if request.session?.got2URL?.length > 1
      got2URL = request.session.got2URL
      delete request.session.got2URL
      return response.redirect got2URL
    try
      userId = request.user.id

      cmp = (a, b) ->
        a.name.toLowerCase().localeCompare b.name.toLowerCase()

      loadCreated = (done) ->
        Board.createdBy userId, (err, boards) ->
          throw err if err
          done(null, boards || [])

      loadCollaborated = (done) ->
        Board.collaboratedBy userId, (err, boards) ->
          throw err if err
          done(null, boards || [])

      onLoadComplete = (err, boards) ->
        if boards.created.length + boards.collaborated.length > 0
          response.render 'index',
            user: request.user
            created: boards.created.sort cmp
            collaborated: boards.collaborated.sort cmp
        else # automatically create the user's first board
          boardsController = new BoardsController
          alias = request.user.alias()
          board = boardsController.build "#{alias}'s board", request.user, alias, (err, board)->
            response.redirect "/boards/#{board.id}"

      async.parallel
        "created": loadCreated
        "collaborated": loadCollaborated
      , onLoadComplete

    catch error
      return @throw500 response, error

module.exports = HomeController
