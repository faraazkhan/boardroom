FacebookStrategy = require('passport-facebook').Strategy

Provider = require '../provider'

class Facebook extends Provider
  name: 'facebook'

  passportStrategyClass: FacebookStrategy

  secret:
    clientID: process.env.FACEBOOK_APP_ID || '170007976510137'
    clientSecret: process.env.FACEBOOK_APP_SECRET
    callbackURL: process.env.FACEBOOK_CALLBACK_URL || '/oauth/facebook/callback'

  identityFromOAuth: (accessToken, refreshToken, profile) ->
    profile.avatar = "https://graph.facebook.com/#{profile.id}/picture"
    profile

module.exports = new Facebook
