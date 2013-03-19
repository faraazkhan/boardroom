ApplicationController = require './application'
BoardsController = require '../controllers/boards'
Board = require '../models/board'
oauth = require 'oauth'

twitterAuth = new oauth.OAuth(
  "https://api.twitter.com/oauth/request_token",
  "https://api.twitter.com/oauth/access_token", 
  process.env.TWITTER_KEY, process.env.TWITTER_SECRET, 
  "1.0A", null, "HMAC-SHA1" )

googleAuth = new oauth.OAuth2 process.env.GOOGLE_CLIENT_KEY, process.env.GOOGLE_SECRET, "", 
  "https://accounts.google.com/o/oauth2/auth", "https://accounts.google.com/o/oauth2/token"

facebookAuth = new oauth.OAuth2 process.env.FACEBOOK_CLIENT_KEY, process.env.FACEBOOK_SECRET, 'https://graph.facebook.com'

authenticateWithTwitter = (request,response) ->
  twitterAuth.getOAuthRequestToken( {
      screen_name: request.body.user_id
    }, 
    (err, oauthToken, oauthTokenSecret) =>
      if err
        return response.render 'login'

      request.session['twitter_redirect_url']= request.originalUrl
      request.session.auth ?= {}
      request.session.auth["twitter_user_id"] = request.body.user_id
      request.session.auth["twitter_oauth_token_secret"]= oauthTokenSecret
      request.session.auth["twitter_oauth_token"]= oauthToken
      response.redirect("http://twitter.com/oauth/authenticate?oauth_token=#{oauthToken}&force_login=true"+
          "&screen_name=#{encodeURIComponent(request.body.user_id)}")
  )

authenticateWithGoogle = (request,response) ->
  response.redirect googleAuth.getAuthorizeUrl
    redirect_uri: "#{request.protocol}://#{request.header('host')}/auth/google_callback"
    scope: "https://www.googleapis.com/auth/userinfo.email"
    response_type: 'code'

authenticateWithFacebook = (request,response) ->
  response.redirect facebookAuth.getAuthorizeUrl
    redirect_uri: "#{request.protocol}://#{request.header('host')}/auth/facebook_callback"
    scope: 'email'

completeLogin = (request, response) ->
  redirect_url = request.session?.post_auth_url ? '/'
  if redirect_url.match /^\/login/
    redirect_url = '/'

  user_id = request.session.user_id
  request.session = user_id: user_id

  createdBoards      = (Board.sync.createdBy user_id) || []
  collaboratedBoards = (Board.sync.collaboratedBy user_id) || []

  if (createdBoards.length + collaboratedBoards.length > 0) or redirect_url != '/'
    response.redirect redirect_url
  else
    boardsController = new BoardsController
    board = boardsController.build "#{user_id}'s board", user_id
    response.redirect "/boards/#{board.id}"

class SessionsController extends ApplicationController
  new: (request, response) ->
    response.render 'login'

  create: (request, response, next) ->
    if ! request.body.user_id
      return response.render 'login'

    if /^@/.exec request.body.user_id
      authenticateWithTwitter request, response
    else
      authenticateWithFacebook request, response

  twitterCallback: (request, response) =>
    if request.query.oauth_token == request.session.auth.twitter_oauth_token
      request.session.user_id = request.session.auth.twitter_user_id
      completeLogin(request, response)

  googleCallback: (request, response) ->
    if  ! request.query || request.query.error_reason == 'user_denied' || ! request.query.code
      return response.render 'login'

    try
      access_token = googleAuth.sync.getOAuthAccessToken request.query.code,
         redirect_uri: "#{request.protocol}://#{request.header('host')}/auth/google_callback"
         grant_type: 'authorization_code'

      profile = googleAuth.sync.getProtectedResource "https://www.googleapis.com/oauth2/v1/userinfo", access_token

      user = JSON.parse(profile)
      request.session.user_id = user.email
      completeLogin(request, response)
    catch e
      console.log "google authentication failed", e
      response.render 'login'

  facebookCallback: (request, response) ->
    if  ! request.query || request.query.error_reason == 'user_denied' || ! request.query.code
      return response.render 'login'

    try
      access_token = facebookAuth.sync.getOAuthAccessToken request.query.code,
         redirect_uri: "#{request.protocol}://#{request.header('host')}/auth/facebook_callback"

      profile = facebookAuth.sync.getProtectedResource "https://graph.facebook.com/me", access_token

      user = JSON.parse(profile)
      request.session.user_id = user.email
      completeLogin(request, response)
    catch e
      console.log "google authentication failed", e
      response.render 'login'

  destroy: (request, response) ->
    request.session = {}
    response.redirect '/'

module.exports = SessionsController
