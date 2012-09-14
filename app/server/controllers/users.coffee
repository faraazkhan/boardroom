crypto = require 'crypto'
ApplicationController = require './application'
User = require './../models/user'

class UsersController extends ApplicationController
  avatar: (request, response) ->
    response.redirect User.avatar_for(request.params.user_id)

module.exports = UsersController
