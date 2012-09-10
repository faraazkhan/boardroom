{ ApplicationController } = require './application'

class HomeController extends ApplicationController
  index: (request, response) ->
    response.redirect '/boards'

module.exports = { HomeController }
