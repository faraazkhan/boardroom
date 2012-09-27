Router = require "#{__dirname}/../../../lib/router"

class LoggedInRouter extends Router
  constructor: (user = 'user') ->
    @user = user
    super()

  authenticate: (request, response, next) =>
    request.session = { user_id: @user }
    next()

  createSocketNamespace: (request, response, next) ->
    next()

module.exports = LoggedInRouter
