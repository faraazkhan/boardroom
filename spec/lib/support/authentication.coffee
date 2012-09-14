Router = require "#{__dirname}/../../../lib/routes"

class LoggedInRouter extends Router
  authenticate: (request, response, next) ->
    request.session = { user_id: 1 }
    next()

  createSocketNamespace: (request, response, next) ->
    next()

module.exports = LoggedInRouter
