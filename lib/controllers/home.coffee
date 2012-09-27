ApplicationController = require './application'
Board = require './../models/board'

class HomeController extends ApplicationController
  index: (request, response) =>
    user = request.session.user_id
    Board.created_by user, (error, created) ->
      return @throw500 response, error if error?
      Board.collaborated_by user, (error, collaborated) ->
        return @throw500 response, error if error?
        cmp = (a, b) ->
          a.name.toLowerCase().localeCompare b.name.toLowerCase()
        response.render 'index',
          user: request.session
          created: created.sort cmp
          collaborated: collaborated.sort cmp

module.exports = HomeController
