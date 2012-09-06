express         = require 'express'
cookies         = require 'cookie-sessions'
connectAssets   = require 'connect-assets'
sockets         = require './sockets'
home            = require './controllers/home'
sessions        = require './controllers/sessions'
boards          = require './controllers/boards'
users           = require './controllers/users'

app = express.createServer()
boardNamespaces = {}

sockets.listen boardNamespaces, app

app.configure ->
  app.set "views", "#{__dirname}/../views/"
  app.set "view engine", "jade"

  app.use connectAssets()
  app.use express.bodyParser()
  app.use express.static "#{__dirname}/../public"
  app.use cookies(secret: 'a7c6dddb4fa9cf927fc3d9a2c052d889', session_key: 'carbonite')
  app.error (error, request, response) ->
    console.error(error.message)
    if (error.stack)
      console.error error.stack.join("\n")
    response.render "500", { status: 500, error: error }

requireAuth = (request, response, next) ->
  request.session ?= {}
  if request.session.user_id
    return next()
  request.session.post_auth_url = request.url
  response.redirect '/login'

homeController = new home.HomeController
app.get "/", requireAuth, homeController.index

sessionsController = new sessions.SessionsController
app.get "/login", sessionsController.new
app.post "/login", sessionsController.create
app.get "/logout", sessionsController.destroy

boardsController = new boards.BoardsController boardNamespaces
app.get "/boards", requireAuth, boardsController.index
app.get "/boards/:board", requireAuth, boardsController.show
app.get "/boards/:board/info", boardsController.info

usersController = new users.UsersController
app.get "/user/avatar/:user_id", usersController.avatar

app.listen parseInt(process.env.PORT) || 7777
