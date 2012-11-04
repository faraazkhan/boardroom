class boardroom.views.Group extends Backbone.View
  className: 'group'
  cardViews: []

  attributes: ->
    id: @model.id

  events: {}

  initialize: (attributes) ->
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

  update: (data) =>
    if data.x?
      @moveTo x: data.x, y: data.y
      @showNotice user: data.author, message: data.author
      @groupLock.lock 500
    if data.z?
      @$el.css 'z-index', data.z

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

  initializeDraggable: ->
    @$el.draggable
      isTarget: (target) ->
        return false if $(target).is 'textarea'
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

  snapTo: (groupView) ->
    cards = @model.get('cards')
    for card in cards
      do (card)->
        groupView.displayNewCard card
        # emit move card to neew group
    boardModel = @model.get('board') 
    console.log "snapTo!!!!!"
    @socket.emit 'board.merge-groups',
      _id: boardModel.id
      parentGroupId: @model.id
      otherGroupId: groupView.model.id
      author: boardModel.get('user_id')

    # pos = $(target).position()
    # @moveTo x: pos.left + 10, y: pos.top + 20
    # @emitMove()

  emitMove: () ->
    @socket.emit 'group.update',
      _id: @model.id
      x: @left()
      y: @top()
      author: @model.get('board').get('user_id')

  displayNewCard: (data) ->
    bindings = 
      'group': @model
      'board': (@model.get 'board') 
    if data.set? # check if data is a BackboneModel or not
      data.set bindings
      card = data
    else 
      card = new boardroom.models.Card _.extend(data, bindings)
    cardView = new boardroom.views.Card
      model: card
      socket: @socket
    @$el.append cardView.render().el
    cardView.adjustTextarea()
    @cardViews.push cardView

  render: ->
    @$el
      .css
        left: @model.get('x')
        top: @model.get('y')
        'z-index': @model.get('z')
    @
