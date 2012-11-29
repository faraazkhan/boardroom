class boardroom.views.Group extends boardroom.views.Base
  className: 'group'
  cardViews: []

  template: _.template """
    <div class="background"></div>
    <div class='notice'></div>
    <input type='text' class='name' value="<%=name%>" placeholder="group name"></input>
  """

  attributes: ->
    id: @model.id

  events:
    'keyup .name': 'hiChangeGroupName'
    'dblclick':    'hiRequestNewCard'

  initialize: (attributes) ->
    { @boardView } = attributes
    super attributes
    @model.set('name', '') unless @model.get('name')
    @render()
    @initializeCards()
    @initializeDraggable()
    @initializeDroppable()

  onLockPoll: ()=>
    @enableEditing '.name'

  initializeSourcePath: ()->
    @sourcePath = 
      boardId: @boardView.model.id
      groupId: @model.id

  initializeCards: () ->
    cards = @model.get('cards')
    @displayNewCard card for card in cards if cards

  initializeDraggable: ->
    @$el.draggable
      minX: @boardView.left() + 12
      minY: @boardView.top()  + 12
      isTarget: (target) ->
        # return false if $(target).is 'input'
        return false if $(target).is '.color'
        return false if $(target).is '.delete'
        true
      onMouseDown: =>
        z = @bringForward()
        @socket.emit 'group.update', { _id: @model.id, z }
      onMouseMove: =>
        @emitMove()
        @resizeHTML()
      startedDragging: =>
        @$el.addClass 'dragging'
      stoppedDragging: =>
        @$el.removeClass 'dragging'

  initializeDroppable: ->
    @$el.droppable
      threshold: 88
      onHover: (event, target) =>
        @addIndicator cssClass:'stackable'
        @emitAddIndicator cssClass:'stackable'
        @$el.removeClass('single-card')
      onBlur: (event, target) =>
        @removeIndicator cssClass:'stackable'
        @emitRemoveIndicator cssClass:'stackable'
        @updateGroup()
      onDrop: (event, target) =>
        $(target).data('view').hiDropOnToGroup event, @
        @$el.removeClass 'stackable'
      shouldBlockHover: (data) =>
        view = $(data.target).data('view')
        groupView = view.groupView if view?
        (@ is groupView) # block a card from dropping onto its own view

  ###
      render
  ###

  render: ->
    @$el
      .html(@template(@model.toJSON()))
      .css
        left: @model.get('x')
        top: @model.get('y')
        'z-index': @model.get('z')
    @updateGroup()
    @

  update: (data) =>
    if data.x?
      @moveTo x: data.x, y: data.y
      @showNotice user: data.author, message: data.author
      @authorLock.lock 500
    if data.z?
      @$el.css 'z-index', data.z
    if data.name?
      @disableEditing '.name', data.name
      @authorLock.lock()
      @$('.name').val data.name

  updateCards: (cards) =>
    @displayNewCard card for card in cards
    @updateGroup()

  updateGroup: ()-> # unstyle the group if there is only 1 card
    if 1 < @$('.card').length
      @$('.name').delay(400).fadeIn('slow').find('input').focus() unless @$('.name').is(':visible')
      @$el.removeClass('single-card')
    else
      @$('.name').delay(400).hide()
      @$el.addClass('single-card') unless @$el.is('single-card')

  cardCount: ()->
    @$('.card').length # +++ count subViews, not DOM elements after viewrefactoring

  displayNewCard: (data) ->
    return if !data or @$el.has("#"+ data._id).length
    bindings = 
      'group': @model
      'board': (@model.get 'board') 
    if data.set? # check if we already have a BackboneModel
      data.set bindings
      card = data
    else 
      card = new boardroom.models.Card _.extend(data, bindings)
    cardView = new boardroom.views.Card
      model: card
      groupView: @
      boardView: @boardView
      socket: @socket
    cardView.$el.hide() # animate adding the new card
    @$el.append cardView.render().el
    cardView.$el.slideDown 'fast'
    setTimeout (=>cardView.adjustTextarea()), 88 # let the card render before adjusting text
    @cardViews.push cardView
    @updateGroup()
    @resizeHTML()
    # set the focus if card was just created by this user
    cardView.$('textarea').focus() if cardView.model.get('user_id') is card?.creator
    @removeIndicator cssClass:'stackable'

  ###
      human interaction event handlers
  ###

  hiChangeGroupName: (event) ->
    isEnter = event.keyCode is 13
    if isEnter
      @$('.name').blur()
    else
      @socket.emit 'group.update', _id: @model.get('_id'), name: @$('.name').val()

  hiRequestNewCard: (event) ->
    event.stopPropagation()
    return unless 1 < @$('.card').length # don't add new card unless there is already more than 1

    @socket.emit 'group.card.create',
      sourcePath: @sourcePath
      creator: @boardView.model.get('user_id')
      focus: true

  hiDropOnToGroup: (event, parentGroupView) ->
    if 0==$('#'+parentGroupView.model.id).length
      console.log "Can't drop onto a phantom!"
      return # patch: draggable/dropable handlers still running but shouldn't be (after deleting another group)
    @eventsOff()
    boardModel = @model.get('board')
    @socket.emit 'board.group.merge',
      _id: boardModel.id
      parentGroupId: parentGroupView.model.id
      otherGroupId: @model.id
      author: boardModel.get('user_id')

  hiDropOnToBoard: (event, boardView) -> # noop group can move freely on a board
