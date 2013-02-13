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
    @model.on 'change:hover', (group, hover, options) => @updateHover(hover, options)

    # in the case of a move, we should move it via jquery
    @model.get('cards').on 'add', (card, options) =>
      @displayNewCard card, options

    @model.get('cards').on 'remove', (card, options) =>
      $("##{card.id}").remove()
      @updateGroup()

  onLockPoll: ()=>
    @enableEditing '.name'

  initializeCards: () ->
    cards = @model.get('cards')
    cards.each (card) =>
      @displayNewCard card

  initializeDraggable: ->
    @$el.draggable
    #minX: @boardView.left() + 12
    #minY: @boardView.top()  + 12
      isTarget: (target) ->
        # return false if $(target).is 'input'
        return false if $(target).is '.color'
        return false if $(target).is '.delete'
        true
      onMouseDown: =>
        @model.bringForward()
      onMouseMove: =>
        @model.moveTo @left(), @top()
      startedDragging: =>
        @$el.addClass 'dragging'
      stoppedDragging: =>
        @$el.removeClass 'dragging'

  initializeDroppable: ->
    @$el.droppable
      threshold: 88
      onHover: (event, target) =>
        @model.hover()
      onBlur: (event, target) =>
        @model.blur()
      onDrop: (event, target) =>
        console.log "group.onDrop"
        id = $(target).attr 'id'
        @model.dropCard(id)  if $(target).is('.card')
        @model.dropGroup(id) if $(target).is('.group')
        @model.blur()

  ###
      render
  ###

  render: ->
    @$el.html(@template(@model.toJSON()))
    @updatePosition @model.get('x'), @model.get('y')
    @updateZIndex @model.get('z')
    @updateGroup()
    @

  updateName: (name, options) =>
    @$('.name').val(name).trimInput(80)
    if options?.rebroadcast
      @disableEditing '.name', name
      @authorLock.lock()

  updatePosition: (x, y, options) =>
    @moveTo x: x, y: y
    if options?.rebroadcast
      @showNotice user: @model.get('author'), message: @model.get('author')
      @authorLock.lock 500

  updateZIndex: (z, options) =>
    @$el.css 'z-index', z

  updateHover: (hover, options) =>
    if hover
      @$el.addClass 'stackable'
      @$el.removeClass 'single-card'
    else
      @$el.removeClass 'stackable'
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
    @model.cards().length

  displayNewCard: (card, options) ->
    card.set 'group', @model, { silent: true }
    cardView = new boardroom.views.Card { model: card }
    @renderCardInOrder cardView
    setTimeout ( => cardView.adjustTextarea() ), 100
    @updateGroup()
    @resizeHTML()
    cardView.focus() if card.get('creator') == @model.currentUser()

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
      @model.set 'name', name

  hiRequestNewCard: (event) ->
    event.stopPropagation()
    return unless 1 < @model.cards().length # don't add new card unless there is already more than 1
    @model.createCard()
