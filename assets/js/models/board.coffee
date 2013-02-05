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

  createGroup: ({x, y}) =>
    z = @maxZ()
    group =
      boardId: @get '_id'
      creator: @get 'user_id'
      x: x - 10
      y: y - 10
      z: z + 1
      focus: true
    @get('pendingGroups').add(new boardroom.models.Group(group))

  mergeGroups: (parentId, childId) =>
    console.log "board.mergeGroups: #{parentId}, #{childId}"
    child = @findGroup childId
    childCards = child.get('cards').toArray()
    for card in childCards
      card.set 'groupId', parentId
    @get('groups').remove child

  maxZ: =>
    groups = @get 'groups'
    return 0 unless groups? and groups.length > 0
    maxGroup = groups.max (group) -> ( group.get('z') || 0 )
    maxGroup.get('z') || 0

