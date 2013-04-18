Sockets = require './services/sockets'
HomeController = require './controllers/home'
ContentsController = require './controllers/contents'
SessionsController = require './controllers/sessions'
BoardsController = require './controllers/boards'
UsersController = require './controllers/users'

addRouting = (app, loginProtection, createSocketNamespace) ->
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
  app.post '/boards/:id', loginProtection, boardsController.destroy
  app.post '/boards', loginProtection, boardsController.create

  usersController = new UsersController
  app.get '/user/avatar/:user_id', usersController.avatar

module.exports = addRouting
