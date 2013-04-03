express = require 'express'
cookies = require 'cookie-sessions'
fibrous = require 'fibrous'
logger = require './logger'
pipeline = require './asset_pipeline'
Sockets = require './sockets'
HomeController = require '../controllers/home'
ContentsController = require '../controllers/contents'
SessionsController = require '../controllers/sessions'
BoardsController = require '../controllers/boards'
UsersController = require '../controllers/users'
passport = require 'passport'

class Router

  constructor: ->
    @app = express()
    @app.configure =>
      @app.use @redirectHandler
      @app.set 'views', "#{__dirname}/../views"
      @app.set 'view engine', 'jade'

      @app.use pipeline.middleware
      @app.use express.bodyParser()
      @app.use express.static "#{__dirname}/../../public"
      @app.use cookies(secret: 'a7c6dddb4fa9cf927fc3d9a2c052d889', session_key: 'boardroom')
      @app.use @catchPathErrors
      @app.use passport.initialize()
      @app.use passport.session()

    homeController = new HomeController
    @app.get '/', @protected, homeController.index

    contentsController = new ContentsController
    @app.get '/styles', @protected, contentsController.styles

    sessionsController = new SessionsController
    @app.get '/login', sessionsController.new
    @app.get '/logout', sessionsController.destroy

    @app.get '/oauth/twitter', sessionsController.oauthTwitter
    @app.get '/oauth/twitter/callback', sessionsController.callbackTwitter
    @app.get '/oauth/facebook', sessionsController.oauthFacebook
    @app.get '/oauth/facebook/callback', sessionsController.callbackFacebook
    @app.get '/oauth/google', sessionsController.oauthGoogle
    @app.get '/oauth/google/callback', sessionsController.callbackGoogle

    boardsController = new BoardsController
    @app.get '/boards/:id', @protected, @createSocketNamespace, boardsController.show
    @app.post '/boards/:id', @protected, boardsController.destroy
    @app.post '/boards', @protected, boardsController.create

    usersController = new UsersController
    @app.get '/user/avatar/:user_id', usersController.avatar

  catchPathErrors: (error, request, response, next) ->
    logger.error -> error.message
    if error.stack
      console.error error.stack.join("\n")
    response.render '500', status: 500, error: error

  redirectHandler: (request, response, next) ->
    if request.host.match /.*betterthanstickies.com$/
      url = 'http://boardroom.carbonfive.com' + request.url
      response.redirect(url)
    else
      next()

  protected: (request, response, next) ->
    request.session ?= {}
    if request.user?
      request.session.user_id = request.user.displayUsername()
      next()
    else
      request.session.post_auth_url = request.url
      response.redirect '/login'

  createSocketNamespace: (request, _, next) ->
    Sockets.findOrCreateByBoardId request.params.id
    next()

  start: ->
    server = @app.listen parseInt(process.env.PORT) || 7777
    Sockets.start server

module.exports = Router