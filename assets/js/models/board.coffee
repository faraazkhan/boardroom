class boardroom.models.Board extends Backbone.Model

  initialize: (attributes, options) ->
    groups = new Backbone.Collection _.map(attributes?.groups, (group) -> new boardroom.models.Group(group))
    groups.each (group) => group.set 'board', @, { silent: true }
    @set 'users', {}
    @set 'groups', groups
    userIdentitySet = {}
    userIdentitySet[userId] = new boardroom.models.UserIdentity atts for userId, atts of attributes?.userIdentitySet
    @set 'userIdentitySet', userIdentitySet
    @set 'currentUserId', attributes.currentUserId

  currentUser: -> @userIdentityForId @get 'currentUserId'
  currentUserId: -> @currentUser().userId()

  groups: -> @get 'groups'

  userIdentityForId: (userIdentityId)-> @userIdentitySet()[userIdentityId]
  userIdentitySet: (userIdentityId)-> @get('userIdentitySet') ? {}
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
    creator = @currentUserId()
    group.onSaved = (group) =>
      card = new boardroom.models.Card
        group: group
        groupId: group.id
        creator: creator
        authors: [ creator ]
      group.cards().add card
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
      board: @
      boardId: @id
      x: x - 10
      y: y - 10
      z: @maxZ() + 1
