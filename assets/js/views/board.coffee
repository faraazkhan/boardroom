class boardroom.views.Board extends boardroom.views.Base
  el: '.board'
  groupViews: []

  events:
    'dblclick': 'hiRequestNewCard'

  initialize: (attributes) ->
    @$el.data 'view', @
    { @socket } = attributes
    @initializeSocketEventHandlers()
    @initializeGroups()

  initializeSocketEventHandlers: ->
    @socket.on 'joined', @onJoined
    @socket.on 'connect', @onConnect
    @socket.on 'disconnect', @onDisconnect
    @socket.on 'reconnecting', @onReconnecting
    @socket.on 'reconnect', @onReconnect
    @socket.on 'group.create', @onGroupCreate
    @socket.on 'group.update', @onGroupUpdate
    @socket.on 'group.update-cards', @onGroupUpdateCards
    @socket.on 'group.delete', @onGroupDelete
    @socket.on 'card.update', @onCardUpdate
    @socket.on 'card.delete', @onCardDelete

  initializeGroups: ->
    groups = @model.get('groups')
    @displayNewGroup group for group in groups if groups

  ###
  --------- render ---------
  ###
  displayStatus: (status) ->
    @$('#connection-status').html status
    modal = @$('#connection-status-modal')
    if status then modal.show() else modal.hide()

  displayNewGroup: (data) ->
    if data.set? # check if we already have a BackboneModel
      data.set 'board', @model
      group = data 
    else
      group = new boardroom.models.Group _.extend(data, board: @model)
    groupView = new boardroom.views.Group
      model: group
      socket: @socket
    groupView.$el.hide() # animate adding the new group
    @$el.append groupView.el
    groupView.$el.slideDown('fast')
    @groupViews.push groupView

  ###
  --------- human interaction event handlers ---------
  ###
  hiRequestNewCard: (event) ->
    return unless event.target.className == 'board'
    maxZ = if @groupViews.length
        _.max(@groupViews, (view) -> view.zIndex()).zIndex()
      else
        0
    @socket.emit 'group.create',
      boardId: @model.get('_id')
      creator: @model.get('user_id')
      x: parseInt (event.pageX - $(event.target).offset().left) - 10
      y: parseInt (event.pageY - $(event.target).offset().top)  - 10
      z: maxZ + 1
      focus: true



  ###
  --------- socket handlers ---------
  ###
  onGroupCreate: (data) =>
    @displayNewGroup data

  onGroupUpdate: (data) =>
    groupView = @findView data._id
    groupView.update data

  onGroupUpdateCards: (data) =>
    groupView = @findView data.groupId
    groupView.updateCards data.cards if groupView

  onGroupDelete: (id) =>
    groupView = @findView id
    groupView.eventsOff() # prevent further clicks and drops during animate the delete
    groupView.$el.slideUp 'fast', ()-> groupView.$el.remove()

  onCardUpdate: (data) =>
    cardView = @findView data._id
    cardView.update data

  onCardDelete: (id) =>
    cardView = @findView id
    cardView.eventsOff() # prevent further clicks and drops during animate the delete
    cardView.$el.slideUp 'fast', ()-> cardView.$el.remove()

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
