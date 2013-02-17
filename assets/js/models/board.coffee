class boardroom.models.Board extends Backbone.Model

  initialize: (attributes, options) ->
    attributes ||= {}
    groups = new Backbone.Collection _.map(attributes.groups, (group) ->
      new boardroom.models.Group group
    )
    super attributes, options
    @set 'users', {}
    @set 'groups', groups

  currentUser: -> @get 'user_id'
  groups: -> @get 'groups'

  findCard: (id) ->
    card = null
    @groups().each (group) ->
      card = group.findCard(id) unless card?
    card

  findGroup: (id) ->
    @groups().find (group) -> group.id == id

  findGroupByCid: (cid) ->
    @groups().find (group) -> group.cid == cid

  addUser: (user) =>
    users = @get 'users'
    users[user.user_id] = user
    @set 'users', users

  createGroup: (coords) =>
    group = @newGroupAt coords
    creator = @currentUser()
    group.onSaved = (group) =>
      card =
        creator: creator
        groupId: group.id
        authors: [ creator ]
      group.cards().add(new boardroom.models.Card(card))
    @groups().add group

  mergeGroups: (parentId, childId) =>
    child = @findGroup childId
    childCards = child.get('cards').toArray()
    for card in childCards
      card.set 'groupId', parentId
    @groups().remove child

  dropCard: (id) =>
    card = @findCard id
    coords =
      x: card.get('x') + card.group().get('x')
      y: card.get('y') + card.group().get('y')
    group = @newGroupAt coords
    group.onSaved = (group) =>
      card.set 'groupId', group.id
      card.drop()
    @groups().add group

  dropGroup: (id) =>

  #
  # Utility functions
  #

  maxZ: =>
    groups = @groups()
    return 0 unless groups? and groups.length > 0
    maxGroup = groups.max (group) -> ( group.get('z') || 0 )
    maxGroup.get('z') || 0

  newGroupAt: ({x, y}) =>
    new boardroom.models.Group
      boardId: @id
      x: x - 10
      y: y - 10
      z: @maxZ() + 1
