async = require 'async'
ApplicationController = require './application'
Board = require './../models/board'

class HomeController extends ApplicationController
  index: (request, response) =>
    try
      user = request.session.user_id

      cmp = (a, b) ->
        a.name.toLowerCase().localeCompare b.name.toLowerCase()

      loadCreated = (done) ->
        Board.createdBy user, (err, boards) ->
          throw err if err
          done(null, boards || [])

      loadCollaborated = (done) ->
        Board.collaboratedBy user, (err, boards) ->
          throw err if err
          done(null, boards || [])

      onLoadComplete = (err, boards) ->
        response.render 'index',
          user: request.session
          created: boards.created.sort cmp
          collaborated: boards.collaborated.sort cmp

      async.parallel
        "created": loadCreated
        "collaborated": loadCollaborated
      , onLoadComplete

    catch error
      return @throw500 response, error

module.exports = HomeController
