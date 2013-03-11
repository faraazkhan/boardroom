_ = require 'underscore'
express = require 'express'
cookies = require 'cookie-sessions'
rack = require 'asset-rack'
fs = require 'fs'
fibrous = require 'fibrous'
logger = require './logger'
Sockets = require './sockets'
HomeController = require '../controllers/home'
ContentsController = require '../controllers/contents'
SessionsController = require '../controllers/sessions'
BoardsController = require '../controllers/boards'
UsersController = require '../controllers/users'

class Router
  constructor: ->
    @app = express()
    @app.configure =>
      @app.use @redirectHandler
      @app.set 'views', "#{__dirname}/../views"
      @app.set 'view engine', 'jade'

      assetRack = @assetRack()
      @app.use assetRack
      @app.locals.js = assetRack.js
      @app.locals.css = assetRack.css

      @app.use express.bodyParser()
      @app.use express.static "#{__dirname}/../../public"
      @app.use cookies(secret: 'a7c6dddb4fa9cf927fc3d9a2c052d889',
                       session_key: 'boardroom')
      @app.use fibrous.middleware
      @app.use @catchPathErrors

    homeController = new HomeController
    @app.get '/', @authenticate, homeController.index

    contentsController = new ContentsController
    @app.get '/styles', @authenticate, contentsController.styles

    sessionsController = new SessionsController
    @app.get '/login', sessionsController.new
    @app.post '/login', sessionsController.create
    @app.get '/logout', sessionsController.destroy

    boardsController = new BoardsController
    @app.get '/boards/:id', @authenticate, @createSocketNamespace, boardsController.show
    @app.post '/boards/:id', @authenticate, boardsController.destroy
    @app.post '/boards', @authenticate, boardsController.create

    usersController = new UsersController
    @app.get '/user/avatar/:user_id', usersController.avatar

  assetRack: ->
    jsDir = "#{__dirname}/../../assets/js"
    jsFiles = _(fs.readdirSync(jsDir)).select (file) ->
      file.match /\.(js|coffee)$/
    jsAssets = _(jsFiles).map (file) ->
      url = '/js/' + file.replace('.coffee', '.js')
      new rack.SnocketsAsset
        url: url
        filename: "#{jsDir}/#{file}"

    cssDir = "#{__dirname}/../../assets/css"
    cssFiles = _(fs.readdirSync(cssDir)).select (file) ->
      file.match /^application.less$/
    cssAssets = _(cssFiles).map (file) ->
      url = '/css/' + file.replace('.less', '.css')
      new rack.LessAsset
        url: url
        filename: "#{cssDir}/#{file}"

    assets = jsAssets.concat(cssAssets)
    for asset in assets
      logger.debug -> "Racked up asset: #{asset.url}"
      asset.on 'error', (err) ->
        logger.error -> "Error with asset: #{asset.url}"
        console.log err

    rack = new rack.Rack assets
    rack.css = (name) ->
      rack.tag "/css/#{name}.css"
    rack.js = (name) ->
      rack.tag "/js/#{name}.js"
    rack.on 'complete', -> ( logger.debug -> 'Asset rack up complete' )
    rack

  catchPathErrors: (error, request, response, next) ->
    log.error -> error.message
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
    if request.session.user_id
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
