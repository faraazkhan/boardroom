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
TwitterStrategy = require("passport-twitter").Strategy

# REPLACE ME WITH A REAL DATASTORE
users = {}

passport.serializeUser (user, done)->
  done null, user.id

passport.deserializeUser (id, done)->
  done null, (users[id] || {})

twitterStrategy = new TwitterStrategy( {
  consumerKey: process.env.TWITTER_KEY, 
  consumerSecret: process.env.TWITTER_SECRET
  },
  (token, tokenSecret, profile, done)->
    user = 
      user_id: profile.username
      id: profile.id
    users[profile.id] = user
    done(null, user)
)
passport.use twitterStrategy

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
      @app.use cookies(secret: 'a7c6dddb4fa9cf927fc3d9a2c052d889',
                       session_key: 'boardroom')
      @app.use fibrous.middleware
      @app.use @catchPathErrors

      @app.use passport.initialize()
      @app.use passport.session()

    homeController = new HomeController
    @app.get '/', @authenticate, homeController.index

    contentsController = new ContentsController
    @app.get '/styles', @authenticate, contentsController.styles

    sessionsController = new SessionsController
    @app.get '/login', sessionsController.new
    @app.post '/login', sessionsController.create
    @app.get '/logout', sessionsController.destroy
    @app.get '/login/twitter', passport.authenticate('twitter')
    @app.get '/auth/twitter_callback', (req, res, next)-> 
      fx = passport.authenticate('twitter', { successRedirect: '/', failureRedirect: '/login' })
      fx(req,res,next)

    boardsController = new BoardsController
    @app.get '/boards/:id', @authenticate, @createSocketNamespace, boardsController.show
    @app.post '/boards/:id', @authenticate, boardsController.destroy
    @app.post '/boards', @authenticate, boardsController.create

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

  authenticate: (request, response, next) ->
    request.session ?= {}
    if request.user?.user_id
      request.session = user_id: '@'+request.user.user_id
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
