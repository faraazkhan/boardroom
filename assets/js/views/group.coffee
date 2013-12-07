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

    @model.cards().on 'add', @displayNewCard, @
    @model.cards().on 'remove', @removeCard, @

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
    @model.cards().each @displayNewCard, @

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
        @$el.addClass 'dragging'
      stoppedDragging: =>
        @$el.removeClass 'dragging'

  initializeDroppable: ->
    @$el.droppable
      priority: 0
      onHover: (event, target) =>
        @model.hover()
      onBlur: (event, target) =>
        @model.blur()
      onDrop: (event, target) =>
        id = $(target).attr 'id'
        @model.dropCard(id)  if $(target).is('.card')
        @model.dropGroup(id) if $(target).is('.group')
        @model.blur()

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

  findCardView: (card) =>
    _(@cardViews).find (cv) => cv.model == card

  displayExistingCard: (cardView) =>
    @displayCard cardView

  displayNewCard: (card, cards, options) =>
    return if options?.movecard
    cardView = new boardroom.views.Card { model: card }
    @displayCard cardView
    cardView.trigger 'attach'
    cardView.focus() if card.get('creator') == @model.currentUserId()

  displayCard: (cardView) =>
    @cardViews.push cardView
    @renderCardInOrder cardView
    @updateGroupChrome()
    @resizeHTML()

  removeCard: (card, cards, options) =>
    unless options?.movecard
      cardView = @findCardView card
      @removeCardView card
      cardView.remove()
    @updateGroupChrome()

  removeCardView: (card) =>
    cardView = @findCardView card
    @cardViews.splice @cardViews.indexOf(cardView), 1

  renderCardInOrder: (newCardView) ->
    newCardDiv = newCardView.el
    wasFocused = newCardView.model.focused

    divToInsertBefore = null
    for cardDiv in @$('.card') # identify which card to insert cardView before
      cardModel = @model.findCard $(cardDiv).attr('id')
      if cardModel.get('created') > newCardView.model.get('created')
        divToInsertBefore = cardDiv
        break

    if divToInsertBefore?
      $(newCardDiv).insertBefore divToInsertBefore # insert in order
    else
      @$el.append(newCardDiv) # put it at the end if this is the last card
    newCardView.focus() if wasFocused

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
