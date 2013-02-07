class boardroom.views.Group extends boardroom.views.Base
  className: 'group'
  cardViews: []
  nameDecorated: false

  template: _.template """
    <div class="background"></div>
    <div class='notice'></div>
    <input type='text' class='name' value="<%=name%>" placeholder="group name"></input>
    <button class='add-card'>+</button>
  """

  attributes: ->
    id: @model.id

  events:
    'keyup .name': 'hiChangeGroupName'
    'click .add-card': 'hiRequestNewCard'

  initialize: (attributes) ->
    { @boardView } = attributes
    super attributes
    @model.set('name', '', { silent: true }) unless @model.get('name')
    @render()
    @initializeCards()
    @initializeDraggable()
    @initializeDroppable()

    @model.on 'change:name', (group, name, options) => @updateName(name, options)
    @model.on 'change:x', (group, x, options) => @updatePosition(x, group.get('y'), options)
    @model.on 'change:y', (group, y, options) => @updatePosition(group.get('x'), y, options)
    @model.on 'change:z', (group, z, options) => @updateZIndex(z, options)

    @model.get('cards').on 'add', (card, options) =>
      @displayNewCard card

    @model.get('cards').on 'remove', (card, options) =>
      $("##{card.id}").remove()
      @updateGroup()

  onLockPoll: ()=>
    @enableEditing '.name'

  initializeSourcePath: ()->
    @sourcePath =
      boardId: @boardView.model.id
      groupId: @model.id

  initializeCards: () ->
    cards = @model.get('cards')
    cards.each (card) =>
      @displayNewCard card

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
        @model.bringForward()
      onMouseMove: =>
        @model.moveTo @left(), @top()
        #@resizeHTML()
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
        @model.get('board').mergeGroups @$el.attr('id'), $(target).attr('id')
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

  updateName: (name, options) =>
    unless options.hiEvent
      @disableEditing '.name', name
      @authorLock.lock()
    @$('.name').val(name).trimInput(80)

  updatePosition: (x, y) =>
    @moveTo x: x, y: y
    @showNotice user: @model.get('author'), message: @model.get('author')
    @authorLock.lock 500

  updateZIndex: (z) =>
    @$el.css 'z-index', z

  updateCards: (cards) =>
    @displayNewCard card for card in cards
    @updateGroup()

  updateGroup: ()-> # unstyle the group if there is only 1 card
    if 1 < @cardCount()
      fadeComplete = =>
        if ! @nameDecorated
          @$('.name').trimInput(80)
          @nameDecorated = true
      @$('.name').fadeIn('slow', fadeComplete).find('input').focus() unless @$('.name').is(':visible')
      @$('.add-card').show()
      @$el.removeClass('single-card')
    else
      @$('.name').hide()
      @$('.add-card').hide()
      @$el.addClass('single-card') unless @$el.is('single-card')

  cardCount: ()->
    @$('.card').length # +++ count subViews, not DOM elements after viewrefactoring

  displayNewCard: (data) ->
    return if !data or @$el.has("#"+ data.id).length
    bindings =
      'group': @model
      'board': (@model.get 'board')
    data.set bindings, { silent: true }

    cardView = new boardroom.views.Card
      model: data
      groupView: @
      boardView: @boardView
      socket: @socket
    @renderCardInOrder cardView
    @cardViews.push cardView
    setTimeout ( => cardView.adjustTextarea() ), 100
    @updateGroup()
    @resizeHTML()
    # set the focus if card was just created by this user
    cardView.$('textarea').focus() if @boardView.model.get('user_id') is data.get('creator')
    @removeIndicator cssClass:'stackable'

  renderCardInOrder: (cardView) ->
    elCard = cardView.render().el

    nextCardView = null
    for card in @$('.card') # identify which card to insert cardView before
      view = $(card).data('view')
      if view.model.get('created') > cardView.model.get('created')
        nextCardView = view
        break

    if nextCardView? 
      $(elCard).insertBefore nextCardView.el # insert in order 
    else 
      @$el.append(elCard) # put it at the end if this is the last card


  ###
      human interaction event handlers
  ###

  hiChangeGroupName: (event) ->
    isEnter = event.keyCode is 13
    if isEnter
      @$('.name').blur()
    else
      name = @$('.name').val()
      @model.set 'name', name, { hiEvent: true }

  hiRequestNewCard: (event) ->
    event.stopPropagation()
    return unless 1 < @model.cards().length # don't add new card unless there is already more than 1
    @model.createCard
      sourcePath: @sourcePath
      creator: @boardView.model.get('user_id')
      focus: true

  hiDropOnToBoard: (event, boardView) -> # noop group can move freely on a board
