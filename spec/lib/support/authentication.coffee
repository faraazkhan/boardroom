Router = require "#{__dirname}/../../../lib/router"

routers = []

class LoggedOutRouter extends Router
  constructor: ->
    routers.push @
    super()

  stop: ->
    @app.close()

class LoggedInRouter extends LoggedOutRouter
  constructor: (user = 'user') ->
    @user = user
    super()

  authenticate: (request, response, next) =>
    request.session = { user_id: @user }
    next()

  createSocketNamespace: (request, response, next) ->
    next()

module.exports = { LoggedOutRouter, LoggedInRouter, routers }
