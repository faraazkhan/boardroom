class boardroom.models.User extends Backbone.Model
  @avatar: (handle) ->
    "/user/avatar/#{encodeURIComponent handle}"
