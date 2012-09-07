class ApplicationController
  userInfo: (request) ->
    if request.session and request.session.user_id
      user_id: request.session.user_id

module.exports = { ApplicationController }
