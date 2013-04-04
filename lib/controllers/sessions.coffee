ApplicationController = require './application'
BoardsController = require '../controllers/boards'
Board = require '../models/board'
AuthUser = require '../models/auth_user'
crypto = require 'crypto'

passport = require 'passport'
TwitterStrategy  = require('passport-twitter').Strategy
FacebookStrategy = require('passport-facebook').Strategy
GoogleStrategy   = require('passport-google').Strategy

oauthTwitterCallbackFunctor = (token, tokenSecret, profile, done) ->
  profile.provider = 'twitter'
  profile.providerId = profile.id
  delete profile.id
  profile.avatar = profile._json?.profile_image_url_https
  AuthUser.signIn profile, done

oauthFacebookCallbackFunctor = (accessToken, refreshToken, profile, done) ->
  profile.provider = 'facebook'
  profile.providerId = profile.id
  delete profile.id
  profile.avatar = "https://graph.facebook.com/#{profile.providerId}/picture"
  AuthUser.signIn profile, done

oauthGoogleCallbackFunctor = (identifier, profile, done) ->
  profile.provider = 'google'
  profile.providerId = identifier
  delete profile.id
  emailAddress = profile.emails?[0]?.value
  profile.username = emailAddress
  md5 = crypto.createHash 'md5'
  md5.update emailAddress
  profile.avatar = "http://www.gravatar.com/avatar/#{md5.digest 'hex'}?d=retro"
  AuthUser.signIn profile, done

twitterSecret =
  consumerKey: process.env.TWITTER_KEY
  consumerSecret: process.env.TWITTER_SECRET
  callbackURL: process.env.TWITTER_CALLBACK_URL

facebookSecret = 
  clientID: process.env.FACEBOOK_APP_ID
  clientSecret: process.env.FACEBOOK_APP_SECRET
  callbackURL: process.env.FACEBOOK_CALLBACK_URL

googleSecret =
  realm: process.env.GOOGLE_REALM
  returnURL: process.env.GOOGLE_CALLBACK_URL

passport.serializeUser (user, done)-> done null, user.id
passport.deserializeUser (_id, done)-> AuthUser.findOne { _id }, done

twitterStrategy = new TwitterStrategy twitterSecret, oauthTwitterCallbackFunctor
facebookStrategy = new FacebookStrategy facebookSecret, oauthFacebookCallbackFunctor
googleStrategy = new GoogleStrategy googleSecret, oauthGoogleCallbackFunctor

passport.use twitterStrategy
passport.use facebookStrategy
passport.use googleStrategy

loginFunctorForProvider = (provider)->
  (request, response, next)->
    failureRedirect = '/login'
    successRedirect = '/'
    if request.session?.got2URL?
      successRedirect = request.session?.got2URL
      delete request.session.got2URL

    authenticateFunctor = passport.authenticate(provider, { successRedirect, failureRedirect })
    authenticateFunctor(request,response,next)


class SessionsController extends ApplicationController
  new: (request, response) ->
    response.render 'login', {layout: false}

  destroy: (request, response) ->
    request.session = {}
    response.redirect '/login'

  # OAuth Login redirects and Callbacks
  oauthTwitter: passport.authenticate('twitter')
  callbackTwitter: loginFunctorForProvider('twitter')

  oauthFacebook: passport.authenticate('facebook')
  callbackFacebook: loginFunctorForProvider('facebook')

  oauthGoogle: passport.authenticate('google')
  callbackGoogle: loginFunctorForProvider('google')

module.exports = SessionsController