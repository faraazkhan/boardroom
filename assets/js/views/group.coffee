class boardroom.views.Group extends boardroom.views.Base
  className: 'group'
  nameDecorated: false

  template: _.template """
    <div class='background'></div>
    <div class='notice' style='display: none'></div>
    <input type='text' class='name' placeholder='group name'></input>
    <button class='add-card'>+</button>
  """

  attributes: ->
    id: @model.id

  events:
    'keyup .name'       : 'hiChangeGroupName'
    'click .add-card'   : 'hiRequestNewCard'

  touchEvents:
    'tap .add-card'     : 'hiRequestNewCard'

  initialize: (attributes) ->
    super attributes
    @initializeLocks()

    @on 'attach', @onAttach, @

    @model.on 'change:_id',   @updateId, @
    @model.on 'change:name',  @updateName, @
    @model.on 'change:x',     @updateX, @
    @model.on 'change:y',     @updateY, @
    @model.on 'change:z',     @updateZ, @
    @model.on 'change:hover', @updateHover, @
    @model.on 'change:state', @updateState, @

    @model.cards().on 'add',    @addCard, @
    @model.cards().on 'remove', @removeCard, @
    @model.cards().on 'sort',   @reorderCards, @

  onAttach: =>
    @render()
    @initializeCards()
    @initializeDraggable()
    @initializeDroppable()
    @$('.name').trimInput(80)

  initializeLocks: =>
    @dragLock = @createDragLock()
    @editLock = @createEditLock '.name'

  initializeCards: =>
    @cardViews = []
    @model.cards().each @addCard, @

  initializeDraggable: ->
    boardOffset = @$el.closest('.board').offset()
    @$el.draggable
      minX: boardOffset.left + 5
      minY: boardOffset.top + 5
      isTarget: (target) ->
        return false if $(target).is '.name'
        return false if $(target).is '.add-card'
        return false if $(target).is '.card textarea'
        return false if $(target).is '.card .color'
        return false if $(target).is '.card .plus1 .btn'
        return false if $(target).is '.card .delete'
        true
      onMouseDown: =>
        @model.bringForward()
      onMouseMove: =>
        @model.moveTo @left(), @top()
      startedDragging: =>
        @model.drag()
      stoppedDragging: =>

  initializeDroppable: ->
    @$el.droppable
      priority: 0
      onHover: (event, target) =>
        location = @dropLocation target
        @model.hover location
      onBlur: (event, target) =>
        location = @dropLocation target
        @model.blur location
      onDrop: (event, target) =>
        id = $(target).attr 'id'
        location = @dropLocation target
        @model.dropCard(id, location)  if $(target).is('.card')
        @model.dropGroup(id, location) if $(target).is('.group')
        @model.blur()

  dropLocation: (target) =>
    bounds = $(target).bounds()
    targetId = $(target).attr('id')
    for cardDiv in @$('.card')
      id = $(cardDiv).attr('id')
      unless id == targetId
        cardBounds = $(cardDiv).bounds()
        upper = cardBounds.upperHalf().extendUp(6)
        lower = cardBounds.lowerHalf().extendDown(6)
        if upper.contains bounds.middle()
          return { id, position: 'above' }
        if lower.contains bounds.middle()
          return { id, position: 'below' }
    return { id: targetId }

  ###
      render
  ###

  render: ->
    @$el.html(@template())
    @$el.hammer()
    @updateName @model, @model.get('name')
    @updatePosition @model.get('x'), @model.get('y')
    @updateZ @model, @model.get('z')
    @updateGroupChrome()
    @

  updateId: (group, id, options) =>
    @$el.attr('id', id)

  updateName: (group, name, options) =>
    if @$('.name').val() != name
      @$('.name').val(name).adjustWidth()
    if options?.rebroadcast
      userIdentity = @model.board().userIdentityForId group.get 'author'
      @editLock.lock(1000, userIdentity.get('avatar'), "#{userIdentity.get('displayName')} is typing...") if userIdentity?

  updateX: (group, x, options) =>
    @updatePosition x, group.get('y'), options

  updateY: (group, y, options) =>
    @updatePosition group.get('x'), y, options

  updatePosition: (x, y, options) =>
    @moveTo x: x, y: y
    if options?.rebroadcast
      userIdentity = @model.board().userIdentityForId @model.get 'author'
      @dragLock.lock(1000, userIdentity.get('avatar'), userIdentity.get('displayName')) if userIdentity?

  updateZ: (group, z, options) =>
    @$el.css 'z-index', z

  updateHover: (group, hover, options) =>
    if hover
      @$el.addClass 'stackable'
      @$el.removeClass 'single-card'
    else
      @$el.removeClass 'stackable'
      @updateGroupChrome()

  updateState: (group, state, options) =>
    previous = group.previous 'state'
    @$el.removeClass previous if previous
    @$el.addClass state if state

  updateGroupChrome: ->
    if @model.cards().length > 1
      fadeComplete = =>
        if ! @nameDecorated
          @$('.name').adjustWidth()
          @nameDecorated = true
      @$('.name').fadeIn('slow', fadeComplete).find('input').focus() unless @$('.name').is(':visible')
      @$('.add-card').show()
      @$el.removeClass('single-card')
    else
      @$('.name').hide()
      @$('.add-card').hide()
      @$el.addClass('single-card') unless @$el.is('single-card')

  addCard: (card, cards, options) =>
    return if options?.movecard
    cardView = new boardroom.views.Card { model: card }
    @displayCardView cardView
    cardView.trigger 'attach'
    cardView.focus() if card.get('creator') == @model.currentUserId()

  removeCard: (card, cards, options) =>
    cardView = @findCardView card
    @removeCardView card
    @updateGroupChrome()
    cardView.remove() unless options?.movecard

  findCardView: (card) =>
    _(@cardViews).find (cv) => cv.model == card

  displayCardView: (cardView) =>
    @cardViews.push cardView
    focused = cardView.model.focused
    @$el.append cardView.el
    @reorderCards()
    cardView.focus() if focused
    @updateGroupChrome()
    @resizeHTML()

  removeCardView: (card) =>
    cardView = @findCardView card
    @cardViews.splice @cardViews.indexOf(cardView), 1

  reorderCards: =>
    @logger.debug 'views.Group.reorderCards()'
    # re-ordering blurs, so let's re-focus as necessary
    focused = _(@cardViews).find (cv) -> cv.model.focused
    ordered = _(@$('.card')).sort (a, b) =>
      cardA = @model.findCard $(a).attr('id')
      cardB = @model.findCard $(b).attr('id')
      @model.cardSorter cardA, cardB
    $(ordered).appendTo @$el
    focused.focus() if focused?

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
