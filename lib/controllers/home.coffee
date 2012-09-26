ApplicationController = require './application'
Board = require './../models/board'

class HomeController extends ApplicationController
  index: (request, response) =>
    user = request.session.user_id
    Board.created_by user, (error, created) ->
      return @throw500 response, error if error?
      Board.collaborated_by user, (error, collaborated) ->
        return @throw500 response, error if error?
        response.render 'index',
          user: request.session
          created: created
          collaborated: collaborated

module.exports = HomeController
