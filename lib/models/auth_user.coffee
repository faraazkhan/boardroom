{ mongoose } = require './db'
crypto = require 'crypto'

PROVIDER_TWITTER = 'twitter'
PROVIDER_FACEBOOK = 'facebook'
PROVIDER_GOOGLE = 'google'
PROVIDER_EMAIL = 'email'
PROVIDER_USERNAME = 'username'

SocialProfile = new mongoose.Schema
  providerId: String
  provider : String
  username: String
  avatar: String
  info: {}

AuthUserSchema = new mongoose.Schema
  created : Date
  updated : Date
  loginStats: {} # loginCount, lastLoginDate, lastLoginProvider
  socialProfiles: [SocialProfile] # keep all social profiles for this user (twitter, fb, email, username/password, etc)
 
AuthUserSchema.pre 'save', (next) ->
  @created = new Date() unless @created?
  @updated = new Date()
  next()

AuthUserSchema.statics =

  findByTwitterId:  (twitterId, cb)  -> @findByProviderId PROVIDER_TWITTER, twitterId, cb
  findByFacebookId: (facebookId, cb) -> @findByProviderId PROVIDER_FACEBOOK, facebookId, cb
  findByGoogleId:   (googleId, cb)   -> @findByProviderId PROVIDER_GOOGLE, googleId, cb
  findByEmail:      (email, cb)      -> @findByProviderId PROVIDER_EMAIL, email, cb
  findByUsername:   (username, cb)   -> @findByProviderId PROVIDER_USERNAME, username, cb

  findByProviderId: (provider, providerId, cb) ->
    @findOne { 'socialProfiles.provider': provider , 'socialProfiles.providerId': providerId }, cb

AuthUserSchema.methods =
  twitterProfile: -> @profileFor PROVIDER_TWITTER
  facebookProfile: -> @profileFor 'facebook'
  googleProfile: -> @profileFor 'google'
  emailProfile: -> @profileFor 'email'
  usernameProfile: -> @profileFor 'username'

  profileFor: (provider)->
    profile = null
    profile ?= p for p in @socialProfiles when p.provider is provider
    profile

  setSocialProfile: (profile)-> # replace existing profile for profile.provider

  avatar: ->
    currentProfile = profileFor @loginStats.lastLoginProvider
    currentProfile ?= @twitterProfile() || @facebookProfile() || @googleProfile() || @emailProfile() || usernameProfile()
    currentProfile?.avatar

AuthUser = mongoose.model 'AuthUser', AuthUserSchema

module.exports = AuthUser
