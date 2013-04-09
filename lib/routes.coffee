Sockets = require './services/sockets'
HomeController = require './controllers/home'
ContentsController = require './controllers/contents'
SessionsController = require './controllers/sessions'
BoardsController = require './controllers/boards'
UsersController = require './controllers/users'

addRouting = (app, authenticate, createSocketNamespace) ->
  homeController = new HomeController
  app.get '/', authenticate, homeController.index

  contentsController = new ContentsController
  app.get '/styles', authenticate, contentsController.styles

  sessionsController = new SessionsController
  app.get '/login', sessionsController.new
  app.post '/login', sessionsController.create
  app.get '/logout', sessionsController.destroy

  boardsController = new BoardsController
  app.get '/boards/:id', authenticate, createSocketNamespace, boardsController.show
  app.post '/boards/:id', authenticate, boardsController.destroy
  app.post '/boards', authenticate, boardsController.create

  usersController = new UsersController
  app.get '/user/avatar/:user_id', usersController.avatar

  app.get '/foo', (request, response) -> respone.send('foo')


module.exports = addRouting
