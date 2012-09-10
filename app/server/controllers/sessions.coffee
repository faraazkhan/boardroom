{ ApplicationController } = require './application'

class SessionsController extends ApplicationController
  new: (request, response) ->
    response.render 'login'

  create: (request, response) ->
    request.session = user_id: request.body.user_id
    response.redirect request.session.post_auth_url || '/'
    delete request.session.post_auth_url

  destroy: (request, response) ->
    request.session = {}
    response.redirect '/'

module.exports = { SessionsController }
