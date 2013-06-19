TwitterStrategy = require('passport-twitter').Strategy

Provider = require '../provider'

class Twitter extends Provider
  name: 'twitter'

  passportStrategyClass: TwitterStrategy

  secret:
    consumerKey: process.env.TWITTER_KEY || 'GTCNZRp7ZAzq5ByFyLk4cQ'
    consumerSecret: process.env.TWITTER_SECRET
    callbackURL: process.env.TWITTER_CALLBACK_URL || '/oauth/twitter/callback'

  identityFromOAuth: (token, tokenSecret, profile) ->
    profile.avatar = profile._json?.profile_image_url_https
    profile

module.exports = new Twitter
