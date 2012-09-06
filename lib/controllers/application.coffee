class ApplicationController
  userInfo: (request) ->
    if request.session && request.session.user_id
      user_id:request.session.user_id

  requireAuth: (request, response, next) ->
    request.session ?= {}
    if request.session.user_id
      return next()
    request.session.post_auth_url = request.url
    response.redirect '/login'

module.exports = {
  ApplicationController
}
