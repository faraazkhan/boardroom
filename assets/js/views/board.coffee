class boardroom.views.Board extends Backbone.View
  el: '.board'
  cardViews: []

  events:
    'dblclick': 'requestNewCard'

  initialize: (attributes) ->
    { @socket } = attributes
    @initializeSocketEventHandlers()
    @initializeCards()

  initializeSocketEventHandlers: ->
    @socket.on 'joined', @onJoined
    @socket.on 'connect', @onConnect
    @socket.on 'disconnect', @onDisconnect
    @socket.on 'reconnecting', @onReconnecting
    @socket.on 'reconnect', @onReconnect
    @socket.on 'card.create', @onCardCreate
    @socket.on 'card.update', @onCardUpdate
    @socket.on 'card.delete', @onCardDelete

  initializeCards: ->
    for card in @model.get('cards')
      @displayNewCard card

  displayStatus: (status) ->
    @$('#connection-status').html status
    modal = @$('#connection-status-modal')
    if status then modal.show() else modal.hide()

  findCardView: (id) ->
    _.detect @cardViews, (cardView) ->
      cardView.model.id is id

  requestNewCard: (event) ->
    return unless event.target.className == 'board'
    maxZ = if @cardViews.length
        _.max(@cardViews, (view) -> view.zIndex()).zIndex()
      else
        0
    @socket.emit 'card.create',
      boardId: @model.get('_id')
      creator: @model.get('user_id')
      x: parseInt (event.pageX - $(event.target).offset().left) - 10
      y: parseInt (event.pageY - $(event.target).offset().top)  - 10
      z: maxZ + 1
      focus: true

  displayNewCard: (data) ->
    card = new boardroom.models.Card _.extend(data, board: @model)
    cardView = new boardroom.views.Card
      model: card
      socket: @socket
    @$el.append cardView.render().el
    cardView.adjustTextarea()
    @cardViews.push cardView

  # --------- socket handlers ---------

  onCardUpdate: (data) =>
    cardView = @findCardView data._id
    cardView.update data

  onCardCreate: (data) =>
    @displayNewCard data

  onCardDelete: (id) =>
    cardView = @findCardView id
    cardView.remove()

  onConnect: =>
    @socket.emit 'join', user_id: @model.get('user_id')

  onDisconnect: =>
    @displayStatus 'Disconnected'

  onReconnect: =>
    @displayStatus null

  onReconnecting: =>
    @displayStatus 'Reconnecting...'

  onJoined: (data) =>
    @model.addUser data
