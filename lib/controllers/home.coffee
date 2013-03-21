require 'fibrous'
ApplicationController = require './application'
Board = require './../models/board'

class HomeController extends ApplicationController
  index: (request, response) =>
    try
      user = request.user.user_id
      created = (Board.sync.createdBy user) || []
      collaborated = (Board.sync.collaboratedBy user) || []
      cmp = (a, b) ->
        a.name.toLowerCase().localeCompare b.name.toLowerCase()

      response.render 'index',
        user: request.session
        created: created.sort cmp
        collaborated: collaborated.sort cmp

    catch error
      return @throw500 response, error

module.exports = HomeController
