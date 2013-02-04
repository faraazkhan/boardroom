class boardroom.models.User extends boardroom.models.Model
  @avatar: (handle) ->
    "/user/avatar/#{encodeURIComponent handle}"
