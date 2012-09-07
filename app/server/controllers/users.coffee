crypto = require 'crypto'
{ ApplicationController } = require './application'

class UsersController extends ApplicationController
  avatar: (request, response) ->
    if match = /^@(.*)/.exec(request.params.user_id)
      url = "http://api.twitter.com/1/users/profile_image?size=normal&screen_name=#{encodeURIComponent match[1]}"
    else
      md5 = crypto.createHash 'md5'
      md5.update request.params.user_id
      url = "http://www.gravatar.com/avatar/#{md5.digest 'hex'}?d=retro"
    response.redirect url

module.exports = { UsersController }
