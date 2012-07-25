express = require 'express'
sockets = require 'socket.io'
board = require './lib/board'
sessions = require 'cookie-sessions'

app = express.createServer()
boardNamespaces = {};

io = sockets.listen app
io.set 'log level', 1

process.on "uncaughtException", (error) ->
  console.error("Uncaught exception: " + error.message)
  if (error.stack)
    console.log '\nStacktrace:'
    console.log '===================='
    console.log error.stack

app.configure ->
  app.set "views", __dirname + "/views/"
  app.set "view engine", "jade"

  app.use require('connect-assets')()
  app.use express.bodyParser()
  app.use express.static __dirname + '/public'
  app.use sessions(secret: 'a7c6dddb4fa9cf927fc3d9a2c052d889', session_key: 'carbonite')
  app.error ( error, request, response ) ->
    console.error( error.message );
    if ( error.stack )
      console.error error.stack.join( "\n" )
    response.render( "500", { status : 500, error : error } );

userInfo = (request) ->
  if ( request.session && request.session.user_id )
    return { user_id:request.session.user_id };
  return undefined;

requireAuth = ( request, response, next ) ->
  if !request.session
    request.session = {}
  if request.session.user_id
    return next()
  request.session.post_auth_url = request.url
  response.redirect "/login"

app.get "/", requireAuth, (request, response) ->
  response.redirect("/boards")

app.get "/login", (request, response) ->
  response.render "login"

app.post "/login", (request, response) ->
  if !request.session
    request.session = {}
  console.log request.body
  request.session.user_id = request.body.user_id
  response.redirect request.session.post_auth_url || '/'
  delete request.session.post_auth_url

app.get "/logout", (request, response) ->
  request.session = {};
  response.redirect("/")


app.get "/boards", requireAuth, (request, response) ->
  board.findBoards {deleted:{$ne:true}}, board.arrayReducer (boards) ->
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
    createBoardSession request.params.board
  response.render "board", { user: userInfo(request) }

app.get "/boards/:board/info", (request, response) ->
  boardName = request.params.board
  board.findCards { boardName:boardName, deleted:{$ne:true} }, board.arrayReducer (cards) ->
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
    url = "http://api.twitter.com/1/users/profile_image?size=normal&screen_name=" + encodeURIComponent(m[1]);
  else
    md5 = require('crypto').createHash('md5');
    md5.update(request.params.user_id);
    url = "http://www.gravatar.com/avatar/" + md5.digest('hex') + "?d=retro";
  response.redirect url

app.listen parseInt(process.env.PORT) || 7777

createBoardSession = (boardName) ->
  boardMembers = {};
  boardNamespace = io
    .of("/boardNamespace/#{boardName}")
    .on 'connection', (socket) ->
      rebroadcast socket, ['move', 'text', 'color']
      socket.on 'join', (user) ->
        boardMembers[user.user_id] = user
        boardNamespace.emit 'joined', user
        board.findOrCreateBoard boardName, user.user_id, (b) -> socket.emit('title_changed', b.title)

      socket.on 'add', (data) ->
        addCard boardNamespace, data
        board.findBoard boardName, (b) ->
          boards_channel.emit 'card_added', b, data.author

      socket.on 'delete', (data) ->
        deleteCard(boardNamespace,data);
        board.findBoard boardName, (b) ->
          boards_channel.emit 'card_deleted', b, data.author

      socket.on 'move_commit', updateCard
      socket.on 'text_commit', updateCard
      socket.on 'color', updateCard

      socket.on 'updateGroup', (data) ->
        board.updateGroup data.boardName, data._id, data.cardIds
        socket.broadcast.emit 'createdOrUpdatedGroup', data

      socket.on 'removeCard', (data) ->
        if data.cardIds.length == 0
          board.removeGroup data.boardName, data._id
        else
          board.updateGroup data.boardName, data._id, data.cardIds
        socket.broadcast.emit 'removedCard', data

      socket.on 'createGroup', (data) ->
        board.createGroup data.boardName, data.groupName, data.cardIds, (group) ->
          socket.broadcast.emit 'createdOrUpdatedGroup', group
          socket.emit 'createdOrUpdatedGroup', group

      socket.on 'title_changed', (data) ->
        board.updateBoard boardName, { title: data.title }
        socket.broadcast.emit 'title_changed', data.title
        board.findBoard boardName, (b) ->
          boards_channel.emit('board_changed', b)

  boardNamespaces[boardName] = boardMembers;


boards_channel = io
  .of("/channel/boards")
  .on 'connection', (socket) ->
    rebroadcast socket, ['delete']
    socket.on 'delete', (deleteBoard) ->
      board.deleteBoard deleteBoard.board_id
      io.of("/boardNamespace/#{deleteBoard.boardName}").emit 'boardDeleted'

rebroadcast = (socket, events) ->
  events.forEach (event) ->
    socket.on event, (data) -> socket.broadcast.emit( event, data )

deleteCard = (boardNamespace, card) ->
  board.removeCard { _id:card._id }, ->
    boardNamespace.emit 'delete', card

addCard = (boardNamespace, card) ->
  board.saveCard card, ( saved ) ->
    boardNamespace.emit 'add', saved

updateCard = (card) ->
  board.updateCard card
  board.findBoard card.board_name, (b) ->
    boards_channel.emit 'user_activity', b, card.author, 'Did something'
