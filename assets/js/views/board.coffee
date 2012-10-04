class boardroom.views.Board extends Backbone.View
  el: '.board'

  events:
    'click .stack-name': 'changeStackName'
    'dblclick': 'requestNewCard'

  initialize: (attributes) ->
    { @socket } = attributes

    _.extend @, boardUtils(@socket, @model)

    @initializeSocketEventHandlers()
    @initializeCards()
    @initializeGroups()
    @initializeCardLockPoller()

  initializeSocketEventHandlers: ->
    @socket.on 'joined', @model.addUser
    @socket.on 'connect', @publishUserJoinedEvent
    @socket.on 'disconnect', @displayDisconnectedStatus
    @socket.on 'reconnecting', @displayReconnectingStatus
    @socket.on 'reconnect', @hideDisconnectedStatus
    @socket.on 'boardDeleted', @redirectToBoardsList
    @socket.on 'add', @displayNewCard
    @socket.on 'move', @updateCardPosition
    @socket.on 'text', @updateCardText
    @socket.on 'removedCard', @removeCardFromGroup
    @socket.on 'createdOrUpdatedGroup', @group.onCreatedOrUpdated
    @socket.on 'group', @onGroup

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

      @group.onCreatedOrUpdated $.extend(group, { _id: groupId })

  initializeCardLockPoller: ->
    @cardLock = new boardroom.models.CardLock
    @cardLock.poll (cardId) =>
      cardView = @findCardView cardId
      cardView.hideNotice()
      cardView.enableEditing()

  publishUserJoinedEvent: =>
    @socket.emit 'join', user_id: @model.get('user_id')

  displayDisconnectedStatus: =>
    @$('#connection-status').html 'Disconnected'
    @$('#connection-status-modal').show()

  displayReconnectingStatus: =>
    @$('#connection-status').html 'Reconnecting...'

  hideDisconnectedStatus: =>
    @$('#connection-status').html ''
    @$('#connection-status-modal').hide()

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
      socket: @socket
    @$el.append cardView.render().el
    cardView.adjustTextarea()
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

  requestNewCard: (event) ->
    return unless event.target.className == 'board'
    @socket.emit 'add',
      boardId: @model.get('_id')
      creator: @model.get('user_id')
      x: parseInt (event.pageX - $(event.target).offset().left) - 10
      y: parseInt (event.pageY - $(event.target).offset().top)  - 10
      focus: true


  # GROUPS
  removeCardFromGroup: (data) =>
    @group.remove $("##{data.cardId}")

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
