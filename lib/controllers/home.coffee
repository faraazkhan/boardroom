async = require 'async'
ApplicationController = require './application'
BoardsController = require './boards'
Board = require './../models/board'

class HomeController extends ApplicationController
  index: (request, response) =>
    go2URL = request.session?.go2URL || '/'
    return response.redirect go2URL unless '/' is go2URL

    try
      user = request.user
      cmp = (a, b) ->
        a.name.toLowerCase().localeCompare b.name.toLowerCase()

      loadCreated = (done) ->
        Board.createdBy user.id, (err, boards) ->
          throw err if err
          done(null, boards || [])

      loadCollaborated = (done) ->
        Board.collaboratedBy user.id, (err, boards) ->
          throw err if err
          done(null, boards || [])

      onLoadComplete = (err, boards) ->
        userIdentity = user.activeIdentity
        if (boards.created.length + boards.collaborated.length > 0)
          response.render 'index',
            userIdentity: userIdentity
            created: boards.created.sort cmp
            collaborated: boards.collaborated.sort cmp
        else
          boardsController = new BoardsController
          displayName = userIdentity.displayName
          boardsController.build "#{displayName}'s board", user._id, (board) ->
            response.redirect "/boards/#{board.id}"

      async.parallel
        "created": loadCreated
        "collaborated": loadCollaborated
      , onLoadComplete

    catch error
      return @throw500 response, error

module.exports = HomeController
