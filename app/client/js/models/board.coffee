class boardroom.models.Board extends Backbone.Model
  addUser: (user) =>
    users = @get 'users'
    users[user.user_id] = user
