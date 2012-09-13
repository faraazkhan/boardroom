class boardroom.views.Board extends Backbone.View
  el: '.board'

  events:
    'click .stack-name': 'changeStackName'

  initialize: (attributes) ->
    { @socket } = attributes

    @boardroom = boardroomFactory @socket, @model

    @initializeSocketEventHandlers()
    @initializeCards()
    @initializeGroups()
    @initializeCardLockPoller()

  initializeSocketEventHandlers: ->
    @socket.on 'joined', @model.addUser
    @socket.on 'connect', @publishUserJoinedEvent
    @socket.on 'boardDeleted', @redirectToBoardsList
    @socket.on 'add', @displayNewCard
    @socket.on 'move', @updateCardPosition
    @socket.on 'text', @updateCardText
    @socket.on 'removedCard', @removeCardFromGroup
    @socket.on 'group', @boardroom.onGroup
    @socket.on 'createdOrUpdatedGroup', @boardroom.group.onCreatedOrUpdated

  initializeCards: ->
    @cardViews = []
    for card in @model.get('cards')
      @displayNewCard card

  initializeGroups: ->
    for groupId, group of @model.get('groups')
      for cardId in group.cardIds
        cardView = @findCardView cardId
        cardView.$el.data 'group-id', groupId
        cardView.$el.off 'mousedown'
        cardView.followDrag()

      @boardroom.group.onCreatedOrUpdated $.extend(group, { _id: groupId })

  initializeCardLockPoller: ->
    @cardLock = new boardroom.models.CardLock
    @cardLock.poll (cardId) =>
      cardView = @findCardView cardId
      cardView.hideNotice()
      cardView.enableEditing()

  publishUserJoinedEvent: =>
    @socket.emit 'join', user_id: @model.get('user_id')

  redirectToBoardsList: ->
    alert 'This board has been deleted by its owner.'
    window.location = '/boards'

  updateCardPosition: (data) =>
    cardView = @findCardView data._id
    cardView.moveTo x: data.x, y: data.y
    cardView.showNotice user: data.moved_by, message: data.moved_by
    @cardLock.lock data._id,
      user_id: data.moved_by
      updated: new Date().getTime()
      move: true
    cardView.bringForward()

  displayNewCard: (data) =>
    card = new boardroom.models.Card _.extend(data, board: @model)
    cardView = new boardroom.views.Card
      model: card
      boardroom: @boardroom
      socket: @socket
    @$el.append cardView.render().el
    cardView.bringForward()
    @cardViews.push cardView

  updateCardText: (data) =>
    cardView = @findCardView data._id
    cardView.disableEditing data.text
    cardView.showNotice user: data.author, message: "#{data.author} is typing..."
    @cardLock.lock data._id,
      user_id: data.author
      updated: new Date().getTime()
    cardView.addAuthor data.author
    cardView.adjustTextarea()
    cardView.bringForward()

  findCardView: (id) ->
    _.detect @cardViews, (cardView) ->
      cardView.model.id is id



  # GROUPS
  removeCardFromGroup: (data) =>
    @boardroom.group.remove $("##{data.cardId}")

  changeStackName: (event) ->
    $stackElement = $ event.target
    offset = $stackElement.offset()
    offset.left -= 1

    $input = $('<input type="text" class="stack-name-edit">')
      .val($stackElement.text())
    $input
      .appendTo($stackElement.parent())
      .offset(offset)
      .focus()
    $stackElement.remove()

    $input.on 'blur change', =>
      $stackElement.text($input.val())
      $stackElement.appendTo($input.parent())
      $input.remove()
      targetGroupId = $stackElement.attr('id').split('-')[0]
      @socket.emit 'updateGroup',
        boardName: board.name
        _id: targetGroupId
        name: $input.val()
