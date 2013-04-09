authenticate = (request, response, next) ->
  request.session ?= {}
  if request.session.user_id
    next()
  else
    request.session.post_auth_url = request.url
    response.redirect '/login'

module.exports = authenticate
