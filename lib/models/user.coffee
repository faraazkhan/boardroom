crypto = require 'crypto'
_ = require 'underscore'

{ mongoose } = require './db'
Identity = require './identity'

userSchema = new mongoose.Schema
  identities: [Identity.schema]
  loginStats: String

userSchema.statics =
  logIn: (identity, callback) ->
    @migrateLegacyUser identity, (err, gotCaptured) =>
      @findOne { 'identities.source': identity.source, 'identities.sourceId': identity.sourceId }, (err, user) ->
        user ?= new User
        user.updateIdentity(identity, callback)

  migrateLegacyUser: (identity, callback)->
    username = "@#{identity.username}" if 'twitter' is identity.source
    username ?= identity.email ? identity.emails?[0]?.value
    @findOne { 'identities.source': 'boardroom-legacy', 'identities.username': username }, (err, user) ->
      return callback(null, false) unless user?
      user.identities = [ identity ]
      user.save callback

  avatarFor: (handle) ->
    if match = /^@(.*)/.exec(handle)
      "http://api.twitter.com/1/users/profile_image?size=normal&screen_name={encodeURIComponent match[1]}"
    else
      md5 = crypto.createHash 'md5'
      md5.update handle
      "http://www.gravatar.com/avatar/{md5.digest 'hex'}?d=retro"

userSchema.methods =
  updateIdentity: (identity, callback) ->
    existingIdentity = _.find @identities, (_identity) -> _identity.source is identity.source
    if existingIdentity?
      existingIdentity.set identity
    else
      @identities.push identity
    @save callback

userSchema.virtual('activeIdentity').get () ->
  identity = @identities[0] ? {}
  {
    userId: @id
    username: identity.username
    displayName: identity.displayName
    email: identity.email
    avatar: identity.avatar
    source: identity.source
  }

User = mongoose.model 'User', userSchema

module.exports = User