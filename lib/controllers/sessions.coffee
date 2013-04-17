ApplicationController = require './application'
BoardsController = require '../controllers/boards'
User = require '../models/user'
Board = require '../models/board'
async = require 'async'
path = require 'path'
fs = require 'fs'
passport = require 'passport'

passport.serializeUser (user, done)-> done null, user._id
passport.deserializeUser (_id, done)-> User.findOne { _id }, done

class SessionsController extends ApplicationController
  authenticator: {}

  constructor: ()->
    @registerAuthenticators()

  registerAuthenticators: ()->
    try
      providers = fs.readdirSync path.resolve __dirname, '../services/authentication/providers/'
      for filename in providers
        authenticator = require "../services/authentication/providers/#{filename}"
        passport.use authenticator.passportStrategy()
        authenticator[authenticator.name] = authenticator
    catch e
      console.warn @name, e.message

  newOAuth: (request,response, next)->
    provider = request.params?.provider
    try
      passport.authenticate(provider)(request,response)
    catch e
      console.error "no registered provider for #{provider}"
      response.redirect '/login'

  createOAuth: (request,response, next)->
    provider = request.params?.provider
    failureRedirect = '/login'
    successRedirect = '/'
    if request.session?.got2URL?
      successRedirect = request.session?.got2URL
      delete request.session.got2URL
    passport.authenticate(provider, { successRedirect, failureRedirect })(request,response, next)

  new: (request, response) ->
    response.render 'login', {layout: false}

  # create: (request, response) ->
  #   redirect_url = request.session?.post_auth_url ? '/'
  #   user_id = request.body.user_id
  #   request.session = user_id: user_id

  #   loadCreatedBoards = (done) ->
  #     Board.createdBy user_id, (err, createdBoards) ->
  #       throw err if err
  #       done(null, createdBoards || [])

  #   loadCollaboratedBoards = (done) ->
  #     Board.collaboratedBy user_id, (err, collaboratedBoards) ->
  #       throw err if err
  #       done(null, collaboratedBoards || [])

  #   onLoadComplete = (err, boards) ->
  #     if (boards.created.length + boards.collaborated.length > 0) or redirect_url != '/'
  #       response.redirect redirect_url
  #     else
  #       boardsController = new BoardsController
  #       boardsController.build "#{user_id}'s board", user_id, (board) ->
  #         response.redirect "/boards/#{board.id}"

  #   async.parallel
  #     "created" : loadCreatedBoards
  #     "collaborated" : loadCollaboratedBoards
  #   , onLoadComplete

  destroy: (request, response) ->
    request.session = {}
    response.redirect '/'

module.exports = SessionsController