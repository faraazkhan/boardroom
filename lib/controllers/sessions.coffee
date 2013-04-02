ApplicationController = require './application'
BoardsController = require '../controllers/boards'
Board = require '../models/board'
AuthUser = require '../models/auth_user'

passport = require 'passport'
TwitterStrategy = require("passport-twitter").Strategy

passport.serializeUser (user, done)-> done null, user.id
passport.deserializeUser (_id, done)-> AuthUser.findOne { _id }, done

twitterStrategy = new TwitterStrategy( {
  consumerKey: process.env.TWITTER_KEY, 
  consumerSecret: process.env.TWITTER_SECRET
  },
  (token, tokenSecret, profile, done)->
    profile.providerId = profile.id
    # console.log '\n\nPassport Profile: \n', profile, '\n\n'
    delete profile.id
    AuthUser.signIn profile, done
)
passport.use twitterStrategy

loginFunctorForProvider = (provider)->
  (req, res, next)->
    authenticateFunctor = passport.authenticate(provider, { successRedirect: '/', failureRedirect: '/login' })
    authenticateFunctor(req,res,next)

class SessionsController extends ApplicationController
  new: (request, response) ->
    response.render 'login', {layout: false}

  create: (request, response) ->
    redirect_url = request.session?.post_auth_url ? '/'
    user_id = request.body.user_id
    request.session = user_id: user_id

    createdBoards      = (Board.sync.createdBy user_id) || []
    collaboratedBoards = (Board.sync.collaboratedBy user_id) || []

    if (createdBoards.length + collaboratedBoards.length > 0) or redirect_url != '/'
      response.redirect redirect_url
    else
      boardsController = new BoardsController
      board = boardsController.build "#{user_id}'s board", user_id
      response.redirect "/boards/#{board.id}"

  destroy: (request, response) ->
    request.session = {}
    response.redirect '/'

  # OAuth Login redirects and Callbacks
  oauthTwitter: passport.authenticate('twitter')
  callbackTwitter: loginFunctorForProvider("twitter")

module.exports = SessionsController