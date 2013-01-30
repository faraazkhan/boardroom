class boardroom.models.Board extends Backbone.Model

  findCard: (id) ->
    get('cards').find (card) ->
      card.id == id

  findGroup: (id) ->
    get('groups').find (group) ->
      group.id == id

  addUser: (user) =>
    users = @get 'users'
    users[user.user_id] = user
