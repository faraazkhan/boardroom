Sockets = require './services/sockets'
HomeController = require './controllers/home'
ContentsController = require './controllers/contents'
SessionsController = require './controllers/sessions'
BoardsController = require './controllers/boards'

addRouting = (env, app, loginProtection, createSocketNamespace) ->
  homeController = new HomeController
  app.get '/', loginProtection, homeController.index

  contentsController = new ContentsController
  app.get '/styles', loginProtection, contentsController.styles

  sessionsController = new SessionsController
  app.get '/login', sessionsController.new
  app.get '/logout', sessionsController.destroy

  app.get '/oauth/:provider', sessionsController.newOAuth
  app.get '/oauth/:provider/callback', sessionsController.createOAuth

  boardsController = new BoardsController
  app.get '/boards/:id', loginProtection, createSocketNamespace, boardsController.show
  app.get '/boards/:id/warm', createSocketNamespace, boardsController.warm unless env == 'production'
  app.post '/boards/:id', loginProtection, boardsController.destroy
  app.post '/boards', loginProtection, boardsController.create

module.exports = addRouting
