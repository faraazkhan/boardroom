crypto = require 'crypto'

{ mongoose } = require './db'
Identity = require './identity'

userSchema = new mongoose.Schema
  identities: [Identity.schema]
  loginStats: String

userSchema.statics =
  logIn: (identity, callback) ->
    @findOne { 'identities.source': identity.source, 'identities.sourceId': identity.sourceId }, 
      (error, user) ->
         return callback(error) if error?
         callback error, user

  avatarFor: (handle) ->
    if match = /^@(.*)/.exec(handle)
      "http://api.twitter.com/1/users/profile_image?size=normal&screen_name={encodeURIComponent match[1]}"
    else
      md5 = crypto.createHash 'md5'
      md5.update handle
      "http://www.gravatar.com/avatar/{md5.digest 'hex'}?d=retro"

User = mongoose.model 'User', userSchema

module.exports = User
