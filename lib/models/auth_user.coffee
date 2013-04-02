{ mongoose } = require './db'

crypto = require 'crypto'

PROVIDER_TWITTER = 'twitter'
PROVIDER_FACEBOOK = 'facebook'
PROVIDER_GOOGLE = 'google'
PROVIDER_EMAIL = 'email'

SocialProfileSchema = new mongoose.Schema
  providerId: String
  provider : String
  username: String
  displayName: String
  emails: Array
  photos: Array
  name: {}
  _json: {}

SocialProfileSchema.methods =
  email:  -> @emails?[0]?.value
  avatar: -> @photos?[0]?.value

SocialProfile = mongoose.model 'SocialProfile', SocialProfileSchema

AuthUserSchema = new mongoose.Schema
  created : Date
  updated : Date
  loginStats: {} # loginCount, lastLoginDate, lastLoginProvider
  socialProfiles: [SocialProfileSchema] # keep all social profiles for this user (twitter, fb, google, email, etc)

AuthUserSchema.pre 'save', (next) ->
  @created = new Date() unless @created?
  @updated = new Date()
  next()

AuthUserSchema.statics =
  signIn: (providerProfile, callback)->
    @findByProviderId providerProfile.provider, providerProfile.providerId, (error, user)->
      return callback(error) if error?

      user = new AuthUser unless user?
      user.touchProviderSignIn providerProfile, callback

  findByTwitterId:  (twitterId, cb)  -> @findByProviderId PROVIDER_TWITTER, twitterId, cb
  findByFacebookId: (facebookId, cb) -> @findByProviderId PROVIDER_FACEBOOK, facebookId, cb
  findByGoogleId:   (googleId, cb)   -> @findByProviderId PROVIDER_GOOGLE, googleId, cb
  findByEmail:      (email, cb)      -> @findByProviderId PROVIDER_EMAIL, email, cb

  findByProviderId: (provider, providerId, cb) ->
    @findOne { 'socialProfiles.provider': provider , 'socialProfiles.providerId': providerId }, cb

AuthUserSchema.methods =
  email: -> @profile().email()
  avatar: -> @profile().avatar()
  username: -> @profile().username
  displayName: -> @profile().displayName
  displayUsername: -> if PROVIDER_TWITTER is p.provider then "@" + @username() else @username()
  profile: -> profileFor @loginStats?.lastProvider

  twitterProfile: -> @profileFor PROVIDER_TWITTER
  facebookProfile: -> @profileFor PROVIDER_FACEBOOK
  googleProfile: -> @profileFor PROVIDER_GOOGLE
  emailProfile: -> @profileFor PROVIDER_EMAIL

  profileFor: (provider)->
    return profile for profile in @socialProfiles when profile.provider is provider

  setSocialProfile: (providerProfile)-> # replace existing profile for profile.provider
    profile = @profileFor(providerProfile.provider)
    if profile?
      profile.set providerProfile
    else
      @socialProfiles.push new SocialProfile providerProfile
    @socialProfiles
  touchProviderSignIn: (providerProfile, callback)->
    @setSocialProfile providerProfile
    numLogins = @loginStats?.loginCount || 0
    @loginStats =
      loginCount: numLogins + 1
      lastLoginAt: new Date()
      lastProvider: providerProfile.provider
    @save callback

  avatar: ->
    currentProfile = profileFor @loginStats.lastLoginProvider
    currentProfile ?= @twitterProfile() || @facebookProfile() || @googleProfile() || @emailProfile() || usernameProfile()
    currentProfile?.avatar

AuthUser = mongoose.model 'AuthUser', AuthUserSchema

module.exports = AuthUser