application = require './application'

class HomeController extends application.ApplicationController
  index: (request, response) ->
    response.redirect "/boards"

module.exports = { HomeController }
