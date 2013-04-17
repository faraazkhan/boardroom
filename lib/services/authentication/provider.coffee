User = require '../../models/user'

class Provider
  passportStrategy: =>
    new @passportStrategyClass @secret, @oauthCallback

  oauthCallback: =>
    oauthDone = arguments[a.length-1]
    oauthDetails = arguments[..-2]

    profile = @buildProfile.apply @, oauthDetails
    profile.provider = @name
    profile.providerId ?= profile.id
    delete profile.id

    User.signIn profile, oauthDone

module.exports = Provider
