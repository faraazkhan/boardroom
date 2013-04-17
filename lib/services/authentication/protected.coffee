module.exports = (request, response, next) ->
  request.session ?= {}
  if request.user?
    request.session.user_id = request.user.id
    next()
  else
    request.session.urlToRedirectToOnLogIn = request.url
    response.redirect '/login'
