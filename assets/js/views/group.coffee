class boardroom.views.Group extends Backbone.View
  className: 'group'
  cardViews: []

  template: _.template """
    <div class='notice'></div>
    <input type='text' class='name' value="<%=name%>" placeholder="Group"></input>
  """

  attributes: ->
    id: @model.id

  events:
    'keyup .name': 'changeGroupName'

  initialize: (attributes) ->
    @render()
    @$el.data 'view', @
    { @socket } = attributes
    @initializeCards()
    @initializeDraggable()
    @initializeDroppable()
    @groupLock = new boardroom.models.CardLock
    @groupLock.poll =>
      @hideNotice()

  initializeCards: () ->
    cards = @model.get('cards')
    @displayNewCard card for card in cards if cards

  initializeDraggable: ->
    @$el.draggable
      isTarget: (target) ->
        return false if $(target).is 'input'
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
      threshold: 50
      onHover: (target) =>
        @$el.addClass 'stackable' unless @$el.is 'stackable'
      onBlur: (target) =>
        @$el.removeClass 'stackable'
      onDrop: (target) =>
        $(target).data('view').snapTo @
        @$el.removeClass 'stackable'

  eventsOff: ->
    @$el.off 'mousedown'
    @$el.off 'click'
    @$el.off 'dblclick'

  changeGroupName: (event) ->
    isEnter = event.keyCode is 13
    if isEnter
      @$el.find('.name').blur()
    else
      @socket.emit 'group.update', _id: @model.get('_id'), name: @$el.find('.name').val()

  update: (data) =>
    if data.x?
      @moveTo x: data.x, y: data.y
      @showNotice user: data.author, message: data.author
      @groupLock.lock 500
    if data.z?
      @$el.css 'z-index', data.z
    if data.name?
      @$el.find('.name').val data.name

  updateCards: (cards) =>
    @displayNewCard card for card in cards

  findView: (id) ->
    $("##{id}").data('view')

  zIndex: ->
    parseInt(@$el.css('z-index')) || 0

  delete: ->
    @socket.emit 'group.delete', @model.id

  showNotice: ({ user, message }) =>
    @$('.notice')
      .html("<img class='avatar' src='#{boardroom.models.User.avatar user}'/><span>#{_.escape message}</span>")
      .show()

  moveTo: ({x, y}) ->
    @$el.css { left: x, top: y }

  hideNotice: ->
    @$('.notice').fadeOut 100

  left: ->
    @$el.position().left

  top: ->
    @$el.position().top

  bringForward: ->
    siblings = @$el.siblings ".#{@className}"
    return if siblings.length == 0

    allZs = _.map siblings, (sibling) ->
      parseInt($(sibling).css('z-index')) || 0
    maxZ = _.max allZs
    return if @zIndex() > maxZ

    newZ = maxZ + 1
    @$el.css 'z-index', newZ
    newZ

  snapTo: (parentGroupView) ->
    if 0==$('#'+parentGroupView.model.id).length
      console.log "Can't drop onto a phantom!"
      return # patch: draggable/dropable handlers still running but shouldn't be (after deleting another group)
    boardModel = @model.get('board')
    @socket.emit 'board.merge-groups',
      _id: boardModel.id
      parentGroupId: parentGroupView.model.id
      otherGroupId: @model.id
      author: boardModel.get('user_id')

  emitMove: () ->
    @socket.emit 'group.update',
      _id: @model.id
      x: @left()
      y: @top()
      author: @model.get('board').get('user_id')

  displayGroupName: ()-> # show group name if more than 1 card in the group
    if 1 < @$el.find('.card').length
      @$el.find('.name').fadeIn('slow') 
    else 
      @$el.find('.name').hide()

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
      socket: @socket
    @$el.append cardView.render().el # animate adding the new card 
    setTimeout (=>cardView.adjustTextarea()), 88 # let the card render before adjusting text
    @cardViews.push cardView
    @displayGroupName()

  render: ->
    @$el
      .html(@template(@model.toJSON()))
      .css
        left: @model.get('x')
        top: @model.get('y')
        'z-index': @model.get('z')
    @displayGroupName()
    @
