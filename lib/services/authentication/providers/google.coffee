crypto = require 'crypto'
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy

Provider = require '../provider'

class Google extends Provider
  name: 'google'

  passportStrategyClass: GoogleStrategy

  secret:
    clientID: process.env.GOOGLE_CLIENT_ID
    clientSecret: process.env.GOOGLE_CLIENT_SECRET
    callbackURL: process.env.GOOGLE_CALLBACK_URL

  authenticationOptions: => 
    {
      scope: [
        'https://www.googleapis.com/auth/userinfo.profile',                                  
        'https://www.googleapis.com/auth/userinfo.email'
      ]
    }

  identityFromOAuth: (accessToken, refreshToken, profile) ->
    profile.email = profile._json?.email
    profile.username = profile.email?.replace(/@.*$/,"");
    # +++ todo find a way to get user's avatar from gmail or google plus or google api or whatever
    md5 = crypto.createHash 'md5'
    md5.update profile.email
    profile.avatar = "http://www.gravatar.com/avatar/#{md5.digest 'hex'}?d=retro"
    profile

module.exports = new Google
