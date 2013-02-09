class boardroom.models.Board extends Backbone.Model

  defaults:
    users: {}
    pendingGroups: new Backbone.Collection()

  initialize: (attributes, options) ->
    attributes ||= {}
    groups = new Backbone.Collection _.map(attributes.groups, (group) -> 
      new boardroom.models.Group group
    )
    super attributes, options
    @set 'groups', groups
    groups.on 'add', (group, options) => @handleGroupCallback(group)

  findCard: (id) ->
    card = null
    @get('groups').each (group) ->
      card = group.findCard(id) unless card?
    card

  findGroup: (id) ->
    @get('groups').find (group) ->
      group.id == id

  addUser: (user) =>
    users = @get 'users'
    users[user.user_id] = user
    @set 'users', users

  createGroup: ({x, y}, callback) =>
    group = new boardroom.models.Group
      boardId: @get '_id'
      x: x - 10
      y: y - 10
      z: @maxZ() + 1
    @addGroupCallback group, (group) =>
      card =
        creator: @get 'user_id'
        focus: true
        groupId: group.id
      group.get('pendingCards').add(new boardroom.models.Card(card))
    @get('pendingGroups').add group

  mergeGroups: (parentId, childId) =>
    console.log "board.mergeGroups: #{parentId}, #{childId}"
    child = @findGroup childId
    childCards = child.get('cards').toArray()
    for card in childCards
      card.set 'groupId', parentId
    @get('groups').remove child

  dropCard: (id) =>
    z = @maxZ()
    card = @findCard id
    group =
      boardId: @get '_id'
      x: card.get('x')
      y: card.get('y')
      z: z + 1
      cards: [ { _id: id } ]
    @get('pendingGroups').add(new boardroom.models.Group(group))
    card.get('group').get('cards').remove card

  dropGroup: (id) =>
    console.log "board.dropGroup"

  #
  # Utility functions
  #

  maxZ: =>
    groups = @get 'groups'
    return 0 unless groups? and groups.length > 0
    maxGroup = groups.max (group) -> ( group.get('z') || 0 )
    maxGroup.get('z') || 0

  #
  # Group Callbacks
  #

  groupCallbacks: {}

  groupLocator: (group) ->
    "#{group.get('x')}-#{group.get('y')}-#{group.get('z')}"

  handleGroupCallback: (group) =>
    gl = @groupLocator group
    cb = @groupCallbacks[gl]
    if cb?
      delete @groupCallbacks[gl]
      f = () -> cb(group)
      setTimeout f, 10

  addGroupCallback: (group, callback) =>
    @groupCallbacks[@groupLocator(group)] = callback
