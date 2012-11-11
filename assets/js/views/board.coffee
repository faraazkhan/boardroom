class boardroom.views.Board extends boardroom.views.Base
  el: '.board'
  className: 'board'
  groupViews: []

  events:
    'dblclick': 'hiRequestNewCard'

  initialize: (attributes) ->
    super attributes
    @initializeSocketEventHandlers()
    @initializeGroups()
    @initializeDroppable()
    @resizeHTML()
    $(window).resize => @resizeHTML()

  initializeSourcePath: ()->
    @sourcePath = 
      boardId: @model.id

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

  initializeDroppable: ->
    @$el.droppable
      threshold: Math.max @$el.height(), @$el.width()
      onHover: (event, target) =>
        @$el.addClass 'stackable' unless @$el.is 'stackable'
      onBlur: (event, target) =>
        @$el.removeClass 'stackable'
      onDrop: (mouseEvent, target) =>
        $(target).data('view').hiDropOnToBoard mouseEvent, @
        @$el.removeClass 'stackable'
      shouldBlockHover: (coordinate) =>
        (return true if group.containsPoint(coordinate)) for group in @groupViews
        return false

  sourcePath: ()-> 
    boardId: @model.id

  ###
      render
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
      boardView: @
      socket: @socket
    groupView.$el.hide() # animate adding the new group
    @$el.append groupView.el
    groupView.$el.slideDown 'fast', ()-> groupView.$el.css 'overflow', 'visible'
    @groupViews.push groupView
    @resizeHTML()

  ###
      utils
  ###

  maxZ: ()->
    return  _.max(@groupViews, (view) -> view.zIndex()).zIndex() if @groupViews.length
    0

  ###
      service calls
  ###

  createNewGroup: ({x, y})->
    z = @maxZ()
    @socket.emit 'group.create',
      boardId: @model.get('_id')
      creator: @model.get('user_id')
      x: x - 10
      y: y - 10
      z: z + 1
      focus: true

  switchGroups: (cardSourcePath, newGroupSourcePath)->
    @socket.emit 'board.card.switch-groups',
      cardSourcePath: cardSourcePath
      newGroupSourcePath: newGroupSourcePath

  ungroupCard: (cardSourcePath, newCoordinate) ->
    z = @maxZ()
    @socket.emit 'board.card.ungroup',
      cardSourcePath: cardSourcePath
      x: newCoordinate.x - 10
      y: newCoordinate.y - 10
      z: z + 1

  ###
      human interaction event handlers
  ###
  hiRequestNewCard: (event) ->
    return unless event.target.className == 'board'
    @createNewGroup @coordinateOfEvent (event)

  ###
      socket handlers
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
