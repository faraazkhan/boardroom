User = require '../../models/user'

class Provider
  registerWithPassport: (passport)->
    try 
      passport.use @passportStrategy()
    catch e
      console.warn @name, e.message

  passportStrategy: =>
    new @passportStrategyClass @secret, @passportCallback

  passportCallback: (args...)=>
    oauthDoneCallback = args[ args.length - 1 ]
    oauthArgs = args[..-2]

    identity = @identityFromOAuth oauthArgs...
    identity.source = @name
    identity.sourceId ?= identity.id
    delete identity.id

    User.logIn identity, oauthDoneCallback

module.exports = Provider