ApplicationController = require './application'

class SessionsController extends ApplicationController
  new: (request, response) ->
    response.render 'login'

  create: (request, response) ->
    redirect_url = request.session?.post_auth_url ? '/'
    request.session = user_id: request.body.user_id
    response.redirect redirect_url

  destroy: (request, response) ->
    request.session = {}
    response.redirect '/'

module.exports = SessionsController
