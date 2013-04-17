FacebookStrategy = require('passport-facebook').Strategy

Provider = require '../provider'

class Facebook extends Provider
  name: 'facebook'

  passportStrategyClass: FacebookStrategy

  secret:
    clientID: process.env.FACEBOOK_APP_ID
    clientSecret: process.env.FACEBOOK_APP_SECRET
    callbackURL: process.env.FACEBOOK_CALLBACK_URL

  buildProfile: (accessToken, refreshToken, profile) ->
    profile.avatar = "https://graph.facebook.com/#{profile.providerId}/picture"
    profile

module.exports = new Facebook
