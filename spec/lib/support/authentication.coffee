Router = require "../../../lib/services/router"
Factory = requre './factories'

routers = []

class LoggedOutRouter extends Router
  constructor: ->
    routers.push @
    super()

  stop: ->
    process.exit 0

class LoggedInRouter extends LoggedOutRouter
  constructor: (user = 'user') ->
    @user = user ? Factory.create 'user'
    super()

  authenticate: (request, response, next) =>
    request.session = { user_id: @user.id }
    next()

  createSocketNamespace: (request, response, next) ->
    next()

module.exports = { LoggedOutRouter, LoggedInRouter, routers }
