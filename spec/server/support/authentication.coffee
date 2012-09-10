{ Router } = require "#{__dirname}/../../../app/server/routes"

class LoggedInRouter extends Router
  authenticate: (request, response, next) ->
    request.session = { user_id: 1 }
    next()

  createSocketNamespace: (request, response, next) ->
    next()

module.exports = { LoggedInRouter }
