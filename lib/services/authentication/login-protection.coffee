module.exports = (request, response, next) ->
  if request.user?
    next()
  else
    request.session ?= {}
    request.session.go2URL ?= request.url
    response.redirect '/login'