class boardroom.models.Board extends Backbone.Model

  initialize: (attributes, options) ->
    attributes ||= {}
    groups = new Backbone.Collection _.map(attributes.groups, (group) ->
      new boardroom.models.Group group
    )
    super attributes, options
    @set 'users', {}
    @set 'pendingGroups', new Backbone.Collection()
    @set 'groups', groups
    groups.on 'add', @handleGroupCallback, @
    @groupCallbacks = {}

  currentUser: -> @get 'user_id'
  groups: -> @get 'groups'
  pendingGroups: -> @get 'pendingGroups'

  findCard: (id) ->
    card = null
    @groups().each (group) ->
      card = group.findCard(id) unless card?
    card

  findGroup: (id) ->
    @groups().find (group) ->
      group.id == id

  addUser: (user) =>
    users = @get 'users'
    users[user.user_id] = user
    @set 'users', users

  createGroup: (coords) =>
    group = @newGroupAt coords
    creator = @currentUser()
    @addGroupCallback group, (group) =>
      card =
        creator: creator
        groupId: group.id
        authors: [ creator ]
      group.get('pendingCards').add(new boardroom.models.Card(card))
    @pendingGroups().add group

  mergeGroups: (parentId, childId) =>
    child = @findGroup childId
    childCards = child.get('cards').toArray()
    for card in childCards
      card.set 'groupId', parentId
    @get('groups').remove child

  dropCard: (id) =>
    card = @findCard id
    coords =
      x: card.get('x') + card.group().get('x')
      y: card.get('y') + card.group().get('y')
    group = @newGroupAt coords
    @addGroupCallback group, (group) =>
      card.set 'groupId', group.id
      card.drop()
    @pendingGroups().add group

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
      boardId: @get '_id'
      x: x - 10
      y: y - 10
      z: @maxZ() + 1

  #
  # Group Callbacks
  #

  handleGroupCallback: (group, options) =>
    pendingGroup = @pendingGroups().find (pg) => pg.locator() == group.locator()
    @pendingGroups().remove pendingGroup
    cb = @groupCallbacks[group.locator()]
    if cb?
      delete @groupCallbacks[group.locator()]
      cb group

  addGroupCallback: (group, callback) =>
    @groupCallbacks[group.locator()] = callback
