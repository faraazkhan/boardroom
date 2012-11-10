class boardroom.views.Group extends boardroom.views.Base
  className: 'group'
  cardViews: []

  template: _.template """
    <div class='notice'></div>
    <input type='text' class='name' value="<%=name%>" placeholder="Group"></input>
  """

  attributes: ->
    id: @model.id

  events:
    'keyup .name': 'hiChangeGroupName'

  initialize: (attributes) ->
    { @boardView } = attributes
    super attributes
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

  initializeDroppable: ->
    @$el.droppable
      threshold: 88
      onHover: (event, target) =>
        @$el.addClass 'stackable' unless @$el.is 'stackable'
      onBlur: (event, target) =>
        @$el.removeClass 'stackable'
      onDrop: (event, target) =>
        $(target).data('view').hiDropOnToGroup event, @
        @$el.removeClass 'stackable'

  ###
  --------- render ---------
  ###
  render: ->
    @$el
      .html(@template(@model.toJSON()))
      .css
        left: @model.get('x')
        top: @model.get('y')
        'z-index': @model.get('z')
    @displayGroupName()
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

  displayGroupName: ()-> # show group name if more than 1 card in the group
    if 1 < @$('.card').length
      @$('.name').fadeIn('slow') 
    else 
      @$('.name').hide()

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
    @$el.append cardView.render().el # animate adding the new card 
    setTimeout (=>cardView.adjustTextarea()), 88 # let the card render before adjusting text
    @cardViews.push cardView
    @displayGroupName()

  ###
  --------- human interaction event handlers ---------  
  ###
  hiChangeGroupName: (event) ->
    isEnter = event.keyCode is 13
    if isEnter
      @$('.name').blur()
    else
      @socket.emit 'group.update', _id: @model.get('_id'), name: @$('.name').val()

  hiDropOnToGroup: (event, parentGroupView) ->
    if 0==$('#'+parentGroupView.model.id).length
      console.log "Can't drop onto a phantom!"
      return # patch: draggable/dropable handlers still running but shouldn't be (after deleting another group)
    boardModel = @model.get('board')
    @socket.emit 'board.merge-groups',
      _id: boardModel.id
      parentGroupId: parentGroupView.model.id
      otherGroupId: @model.id
      author: boardModel.get('user_id')

  hiDropOnToBoard: (event, boardView) -> # noop group can move freely on a board
