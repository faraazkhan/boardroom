class boardroom.models.Board extends Backbone.Model

  initialize: (attributes, options) ->
    groups = new Backbone.Collection _.map(attributes?.groups, (group) -> new boardroom.models.Group(group))
    groups.each (group) => group.set 'board', @, { silent: true }
    @set 'online-users', []
    @set 'groups', groups
    userIdentitySet = {}
    userIdentitySet[userId] = new boardroom.models.UserIdentity atts for userId, atts of attributes?.userIdentitySet
    @set 'userIdentitySet', userIdentitySet
    @set 'currentUserId', attributes.currentUserId

  onlineUsers: ()-> @get('online-users')
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

  setOnlineUsers: (onlineUsers)=>
    for userId, user of onlineUsers
      userModel = @userIdentityForId user.userId
      userModel ?= new boardroom.models.UserIdentity
      userModel.set user
      @onlineUsers().push user.userId unless user.userId in @onlineUsers()
      @userIdentitySet()[user.userId] = userModel

  userJoined: (userId) =>
    console.log "#{userId}: #{@userIdentityForId(userId)?.get('displayName') } joined the board"

  createGroup: (coords) =>
    group = @newGroupAt coords
    creator = @currentUserId()
    group.onSaved = (group) =>
      card = new boardroom.models.Card
        group: group
        groupId: group.id
        creator: creator
        authors: [ creator ]
        order: 0
      group.cards().add card
    @groups().add group

  mergeGroups: (parentId, childId, location) =>
    parent = @findGroup parentId
    child = @findGroup childId
    childCards = child.get('cards').toArray()
    parent.insertCards childCards, location
    @groups().remove child

  dropCard: (id) =>
    card = @findCard id
    coords =
      x: card.get('x') + card.group().get('x')
      y: card.get('y') + card.group().get('y')
    group = @newGroupAt coords
    group.onSaved = (group) =>
      card.set 'groupId', group.id
      card.set 'order', 0
      card.drop()
    @groups().add group

  dropGroup: (id) =>
    group = @findGroup id
    group.drop()

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
