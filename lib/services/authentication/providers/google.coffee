crypto = require 'crypto'
GoogleStrategy = require('passport-google').Strategy

Provider = require '../provider'

class Google extends Provider
  name: 'google'

  passportStrategyClass: GoogleStrategy

  secret:
    realm: process.env.GOOGLE_REALM
    returnURL: process.env.GOOGLE_CALLBACK_URL

  buildProfile: (identifier, profile) ->
    emailAddress = profile.emails?[0]?.value
    profile.username = emailAddress
    md5 = crypto.createHash 'md5'
    md5.update emailAddress
    profile.avatar = "http://www.gravatar.com/avatar/#{md5.digest 'hex'}?d=retro"
    profile

module.exports = new Google
