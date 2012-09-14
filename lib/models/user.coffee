crypto = require 'crypto'

class User
  @avatar_for: (handle) ->
    if match = /^@(.*)/.exec(handle)
      "http://api.twitter.com/1/users/profile_image?size=normal&screen_name=#{encodeURIComponent match[1]}"
    else
      md5 = crypto.createHash 'md5'
      md5.update handle
      "http://www.gravatar.com/avatar/#{md5.digest 'hex'}?d=retro"

module.exports = User
