class boardroom.models.UserIdentity extends Backbone.Model
  @avatar: (handle) ->
    "/user/avatar/#{encodeURIComponent handle}"
