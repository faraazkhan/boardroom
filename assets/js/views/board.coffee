class boardroom.views.Board extends Backbone.View
  el: '.board'

  events:
    'dblclick': 'requestNewCard'

  initialize: (attributes) ->
    { @socket } = attributes

    _.extend @, boardUtils(@socket, @model)

    @initializeSocketEventHandlers()
    @initializeCards()
    @initializeCardLockPoller()

  initializeSocketEventHandlers: ->
    @socket.on 'joined', @model.addUser
    @socket.on 'connect', @publishUserJoinedEvent
    @socket.on 'disconnect', @displayDisconnectedStatus
    @socket.on 'reconnecting', @displayReconnectingStatus
    @socket.on 'reconnect', @hideDisconnectedStatus
    @socket.on 'boardDeleted', @redirectToBoardsList
    @socket.on 'card.create', @displayNewCard
    @socket.on 'card.update', @updateCard

  initializeCards: ->
    @cardViews = []
    for card in @model.get('cards')
      @displayNewCard card

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

  findCardView: (id) ->
    _.detect @cardViews, (cardView) ->
      cardView.model.id is id

  updateCard: (data) =>
    cardView = @findCardView data._id
    cardView.update data

  displayNewCard: (data) =>
    card = new boardroom.models.Card _.extend(data, board: @model)
    cardView = new boardroom.views.Card
      model: card
      socket: @socket
    @$el.append cardView.render().el
    cardView.adjustTextarea()
    cardView.bringForward()
    @cardViews.push cardView

  requestNewCard: (event) ->
    return unless event.target.className == 'board'
    @socket.emit 'card.create',
      boardId: @model.get('_id')
      creator: @model.get('user_id')
      x: parseInt (event.pageX - $(event.target).offset().left) - 10
      y: parseInt (event.pageY - $(event.target).offset().top)  - 10
      focus: true
