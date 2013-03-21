Router = require "../../../lib/services/router"

routers = []

class LoggedOutRouter extends Router
  constructor: ->
    routers.push @
    super()

  stop: ->
    process.exit 0

class LoggedInRouter extends LoggedOutRouter
  constructor: (user = 'user') ->
    @user = user
    super()

  authenticate: (request, response, next) =>
    request.user = { id: @user }
    request.session = { user_id: @user }
    next()

  createSocketNamespace: (request, response, next) ->
    next()

module.exports = { LoggedOutRouter, LoggedInRouter, routers }
