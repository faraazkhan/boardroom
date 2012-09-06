express         = require 'express'
cookies         = require 'cookie-sessions'
connectAssets   = require 'connect-assets'
sockets         = require './sockets'
home            = require './controllers/home'
sessions        = require './controllers/sessions'
boards          = require './controllers/boards'
users           = require './controllers/users'

class Router
  constructor: ->
    @app = express.createServer()
    @app.configure =>
      @app.set "views", "#{__dirname}/../views/"
      @app.set "view engine", "jade"
      @app.use connectAssets()
      @app.use express.bodyParser()
      @app.use express.static "#{__dirname}/../public"
      @app.use cookies(secret: 'a7c6dddb4fa9cf927fc3d9a2c052d889',
                       session_key: 'carbonite')
      @app.error @onError

    homeController = new home.HomeController
    @app.get "/", @authenticate, homeController.index

    sessionsController = new sessions.SessionsController @app
    @app.get "/login", sessionsController.new
    @app.post "/login", sessionsController.create
    @app.get "/logout", sessionsController.destroy

    @socketServer = new sockets.Server
    boardsController = new boards.BoardsController @socketServer
    @app.get "/boards", @authenticate, boardsController.index
    @app.get "/boards/:board", @authenticate, boardsController.show
    @app.get "/boards/:board/info", boardsController.info

    usersController = new users.UsersController
    @app.get "/user/avatar/:user_id", usersController.avatar

  onError: (error, request, response) ->
    console.error(error.message)
    if error.stack
      console.error error.stack.join("\n")
    response.render "500", { status: 500, error: error }

  authenticate: (request, response, next) ->
    request.session ?= {}
    if request.session.user_id
      return next()
    request.session.post_auth_url = request.url
    response.redirect '/login'

  start: ->
    @app.listen parseInt(process.env.PORT) || 7777
    @socketServer.start @app

module.exports = { Router }
