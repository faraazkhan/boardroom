express       = require 'express'
sessions      = require 'cookie-sessions'
connectAssets = require 'connect-assets'
crypto        = require 'crypto'
sockets       = require './sockets'
db            = require './db'
group         = require './group'
board         = require './board'
card          = require './card'

app = express.createServer()
boardNamespaces = {}

sockets.listen boardNamespaces, app

app.configure ->
  app.set "views", "#{__dirname}/../views/"
  app.set "view engine", "jade"

  app.use connectAssets()
  app.use express.bodyParser()
  app.use express.static "#{__dirname}/../public"
  app.use sessions(secret: 'a7c6dddb4fa9cf927fc3d9a2c052d889', session_key: 'carbonite')
  app.error (error, request, response) ->
    console.error(error.message)
    if (error.stack)
      console.error error.stack.join("\n")
    response.render "500", { status: 500, error: error }

userInfo = (request) ->
  if request.session && request.session.user_id
    user_id:request.session.user_id

requireAuth = (request, response, next) ->
  request.session ?= {}
  if request.session.user_id
    return next()
  request.session.post_auth_url = request.url
  response.redirect '/login'

app.get "/", requireAuth, (request, response) ->
  response.redirect "/boards"

app.get "/login", (request, response) ->
  response.render "login"

app.post "/login", (request, response) ->
  request.session ?= {}
  request.session.user_id = request.body.user_id
  response.redirect request.session.post_auth_url || '/'
  delete request.session.post_auth_url

app.get "/logout", (request, response) ->
  request.session = {}
  response.redirect("/")

app.get "/boards", requireAuth, (request, response) ->
  board.findBoards {deleted:{$ne:true}}, db.arrayReducer (boards) ->
    board.findBoardCardCounts (boardCounts) ->
      boardCountsByName = boardCounts.reduce((o,item) ->
        o[item.boardName]=item.count
        return o
      ,{})
      response.render "boards",
        user: userInfo(request)
        boards: boards
        boardCounts: boardCountsByName

app.get "/boards/:board", requireAuth, (request, response) ->
  if !boardNamespaces[request.params.board]
    sockets.createBoardSession request.params.board
  response.render "board", { user: userInfo(request) }

app.get "/boards/:board/info", (request, response) ->
  boardName = request.params.board
  card.findCards { boardName:boardName, deleted:{$ne:true} }, db.arrayReducer (cards) ->
    board.findBoardAllowEmpty boardName, (board) ->
      response.send
        name : boardName
        cards : cards
        groups : board && board.groups || {}
        users : boardNamespaces[boardName] || {}
        user_id : request.session.user_id
        title : boardName

app.get "/user/avatar/:user_id", (request, response) ->
  if m = /^@(.*)/.exec(request.params.user_id)
    url = "http://api.twitter.com/1/users/profile_image?size=normal&screen_name=" + encodeURIComponent(m[1])
  else
    md5 = crypto.createHash('md5')
    md5.update(request.params.user_id)
    url = "http://www.gravatar.com/avatar/" + md5.digest('hex') + "?d=retro"
  response.redirect url

app.listen parseInt(process.env.PORT) || 7777
