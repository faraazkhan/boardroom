User = require '../../models/user'

class Provider
  passportStrategy: =>
    new @passportStrategyClass @secret, @passportCallback

  authenticationOptions: => {}

  passportCallback: (args...)=>
    oauthDoneCallback = args[ args.length - 1 ]
    oauthArgs = args[..-2]

    identity = @identityFromOAuth oauthArgs...
    identity.source = @name
    identity.sourceId ?= identity.id
    delete identity.id

    User.logIn identity, oauthDoneCallback

  isConfigured: ()=> # return false if any secret key is missing
    keysConfigured = (val? for key, val of @secret)
    ok = false for keyConfigured in keysConfigured when not keyConfigured
    ok ?= true

module.exports = Provider