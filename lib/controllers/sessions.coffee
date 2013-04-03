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
  (request, response, next)->
    successRedirect = request.session?.post_auth_url ? '/'
    failureRedirect = '/login'
    authenticateFunctor = passport.authenticate(provider, { successRedirect, failureRedirect })
    authenticateFunctor(request,response,next)


class SessionsController extends ApplicationController
  new: (request, response) ->
    request.session = {}
    response.render 'login', {layout: false}

  destroy: (request, response) ->
    request.session = {}
    response.redirect '/login'

  # OAuth Login redirects and Callbacks
  oauthTwitter: passport.authenticate('twitter')
  callbackTwitter: loginFunctorForProvider("twitter")

module.exports = SessionsController