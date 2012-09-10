express                = require 'express'
cookies                = require 'cookie-sessions'
connectAssets          = require 'connect-assets'
{ Sockets }            = require './sockets'
{ HomeController }     = require './controllers/home'
{ SessionsController } = require './controllers/sessions'
{ BoardsController }   = require './controllers/boards'
{ UsersController }    = require './controllers/users'

class Router
  constructor: ->
    @app = express.createServer()
    @app.configure =>
      @app.set 'views', "#{__dirname}/views/"
      @app.set 'view engine', 'jade'
      @app.use connectAssets(src: "#{__dirname}/../client/")
      @app.use express.bodyParser()
      @app.use express.static "#{__dirname}/../../public"
      @app.use cookies(secret: 'a7c6dddb4fa9cf927fc3d9a2c052d889',
                       session_key: 'carbonite')
      @app.error @render500Page

    homeController = new HomeController
    @app.get '/', @authenticate, homeController.index

    sessionsController = new SessionsController @app
    @app.get '/login', sessionsController.new
    @app.post '/login', sessionsController.create
    @app.get '/logout', sessionsController.destroy

    boardsController = new BoardsController
    @app.get '/boards', @authenticate, boardsController.index
    @app.get '/boards/:board', @authenticate, @createSocketNamespace, boardsController.show
    @app.get '/boards/:board/info', @authenticate, boardsController.info

    usersController = new UsersController
    @app.get '/user/avatar/:user_id', usersController.avatar

  render500Page: (error, request, response) ->
    console.error(error.message)
    if error.stack
      console.error error.stack.join("\n")
    response.render '500', status: 500, error: error

  authenticate: (request, response, next) ->
    request.session ?= {}
    if request.session.user_id
      next()
    else
      request.session.post_auth_url = request.url
      response.redirect '/login'

  createSocketNamespace: (request, _, next) ->
    Sockets.findOrCreateByBoardName request.params.board
    next()

  start: ->
    @app.listen parseInt(process.env.PORT) || 7777
    Sockets.start @app

module.exports = { Router }
