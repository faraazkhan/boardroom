class boardroom.models.UserIdentity extends Backbone.Model
  @avatar: (handle) ->
    "/user/avatar/#{encodeURIComponent handle}"

  userId: ()=> @get 'userId'
  avatar: ()=> @get 'avatar'
  displayName: ()=> @get 'displayName'
