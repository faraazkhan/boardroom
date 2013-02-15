class boardroom.views.Group extends boardroom.views.Base
  className: 'group'
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
    'keyup .name'    : 'hiChangeGroupName'
    'click .add-card': 'hiRequestNewCard'

  initialize: (attributes) ->
    super attributes
    @initializeLock()

    @on 'attach', @onAttach, @

    @model.set('name', '', { silent: true }) unless @model.get('name')

    @model.on 'change:name',  @updateName, @
    @model.on 'change:x',     @updateX, @
    @model.on 'change:y',     @updateY, @
    @model.on 'change:z',     @updateZ, @
    @model.on 'change:hover', @updateHover, @

    # TODO: in the case of a move, we should move it via jquery
    @model.cards().on 'add', @displayNewCard, @
    @model.cards().on 'remove', @removeCard, @

  onAttach: =>
    @render()
    @initializeCards()
    @initializeDraggable()
    @initializeDroppable()

  initializeLock: =>
    onLock = (user, message) =>
      @showNotice user, message if user? and message?
      @disableEditing '.name'
    onUnlock = =>
      @hideNotice()
      @enableEditing '.name'
    @lock = new boardroom.models.Lock onLock, onUnlock

  initializeCards: =>
    @cardViews = []
    @model.cards().each @displayNewCard, @

  initializeDraggable: ->
    boardOffset = @$el.closest('.board').offset()
    @$el.draggable
      minX: boardOffset.left + 5
      minY: boardOffset.top + 5
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
    @updateZ @model, @model.get('z')
    @updateGroupChrome()
    @

  updateName: (group, name, options) =>
    @$('.name').val(name).trimInput(80)
    if options?.rebroadcast
      @lock.lock 1000

  updateX: (group, x, options) =>
    @updatePosition x, group.get('y'), options

  updateY: (group, y, options) =>
    @updatePosition group.get('x'), y, options

  updatePosition: (x, y, options) =>
    @moveTo x: x, y: y
    if options?.rebroadcast
      @lock.lock 1000, @model.get('author'), @model.get('author')

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
          @$('.name').trimInput(80)
          @nameDecorated = true
      @$('.name').fadeIn('slow', fadeComplete).find('input').focus() unless @$('.name').is(':visible')
      @$('.add-card').show()
      @$el.removeClass('single-card')
    else
      @$('.name').hide()
      @$('.add-card').hide()
      @$el.addClass('single-card') unless @$el.is('single-card')

  displayNewCard: (card, options) =>
    card.set 'group', @model, { silent: true }
    cardView = new boardroom.views.Card { model: card }
    @cardViews.push cardView
    @renderCardInOrder cardView
    cardView.trigger 'attach'
    @updateGroupChrome()
    @resizeHTML()
    cardView.focus() if card.get('creator') == @model.currentUser()

  removeCard: (card, options) =>
    cardView = _(@cardViews).find (cv) -> cv.model == card
    @cardViews.splice @cardViews.indexOf(cardView), 1
    cardView.remove()
    @updateGroupChrome()

  renderCardInOrder: (newCardView) ->
    newCardDiv = newCardView.el

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
