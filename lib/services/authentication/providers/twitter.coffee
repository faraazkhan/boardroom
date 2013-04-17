TwitterStrategy = require('passport-twitter').Strategy

Provider = require 'passport'

Twitter extends Provider
  name: 'twitter'

  passportStrategyClass: TwitterStrategy

  secret:
    consumerKey: process.env.TWITTER_KEY
    consumerSecret: process.env.TWITTER_SECRET
    callbackURL: process.env.TWITTER_CALLBACK_URL

  buildProfile: (token, tokenSecret, profile) ->
    profile.avatar = profile._json?.profile_image_url_https
    profile

module.exports = new Twitter
