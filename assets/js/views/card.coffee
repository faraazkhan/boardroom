class boardroom.views.Card extends boardroom.views.Base
  className: 'card'
  template: _.template """
    <div class='header-bar'>
      <span class='delete-btn'>&times;</span>
      <span class='notice' style='display: none'></span>
      <div class='plus-authors'></div>
    </div>
    <textarea></textarea>
    <div class='footer'>
      <div class='plus-count'></div>
      <div class='toolbar'>
        <div class='plus1'>
          <span class='btn'>+1</span>
        </div>
        <div class='colors'>
          <span class='color color-0'></span>
          <span class='color color-1'></span>
          <span class='color color-2'></span>
          <span class='color color-3'></span>
          <span class='color color-4'></span>
        </div>
        <div class='authors'></div>
      </div>
    </div>
  """

  attributes: ->
    id: @model.id

  events: # human interaction event
    'click .color'        : 'hiChangeColor'
    'keyup textarea'      : 'hiChangeText'
    'focus textarea'      : 'hiFocusText'
    'blur textarea'       : 'hiUnFocusText'
    'click .plus1 .btn'   : 'hiIncrementPlusCount'
    'click .delete-btn'   : 'hiDelete'

  touchEvents:
    'tap .color'          : 'hiChangeColor'
    'tap .plus1 .btn'     : 'hiIncrementPlusCount'
    'tap .delete-btn'     : 'hiDelete'

  initialize: (attributes) ->
    super attributes
    @initializeLocks()

    @on 'attach', @onAttach, @

    @model.on 'change:_id',         @updateId, @
    @model.on 'change:colorIndex',  @updateColor, @
    @model.on 'change:text',        @updateText, @
    @model.on 'change:x',           @updateX, @
    @model.on 'change:y',           @updateY, @
    @model.on 'change:order',       @updateOrder, @
    @model.on 'change:hover',       @updateHover, @
    @model.on 'change:state',       @updateState, @
    @model.on 'change:plusAuthors', @updatePlusAuthors, @
    @model.on 'change:authors',     @updateAuthors, @

  onAttach: =>
    @render()
    @initializeDraggable()

  initializeLocks: =>
    @dragLock = @createDragLock()
    @editLock = @createEditLock 'textarea'

  initializeDraggable: =>
    boardOffset = @$el.closest('.board').offset()
    @$el.draggable
      minX: boardOffset.left + 5
      minY: boardOffset.top + 5
      isTarget: (target) =>
        return false if $(target).is 'textarea'
        return false if $(target).is '.color'
        return false if $(target).is '.plus1 .btn'
        return false if $(target).is '.delete'
        true
      isOkToDrag: () =>
        # dont allow card to drag if its the only one in its group (allow the group to drag)
        @model.group().cards().length > 1
      onMouseDown: =>
        @model.group().bringForward()
      onMouseMove: =>
        @model.moveTo @left(), @top()
      startedDragging: =>
        @model.drag()
      stoppedDragging: =>

  ###
      render
  ###

  render: ->
    @$el.html(@template())
    @$el.hammer()
    @$el.find('textarea').css('resize', 'none').autosize { append: "\n" }
    @updateText @model, @model.get('text')
    setTimeout @triggerAutosize, 10
    @updatePosition @model.get('x'), @model.get('y')
    @updateColor @model, @model.get('colorIndex')
    @updateOrder @model, @model.get('order')
    @updateAuthors @model, @model.get('authors')
    @updatePlusAuthors @model, @model.get('plusAuthors')
    @

  updateId: (card, id, options) =>
    @$el.attr('id', id)

  updateColor: (card, color, options) =>
    @$el.removeClassMatching /color-\d+/g
    @$el.addClass "color-#{color ? 2}"

  updateText: (card, text, options) =>
    @$el.find('textarea').val(text)
    @updateILikeIWish()
    if options?.rebroadcast
      @triggerAutosize()
      userIdentity = @model.board().userIdentityForId card.get 'author'
      @editLock.lock(1000, userIdentity.get('avatar'), "#{userIdentity.get('displayName')} is typing...") if userIdentity?

  updateX: (card, x, options) =>
    @updatePosition x, card.get('y'), options

  updateY: (card, y, options) =>
    @updatePosition card.get('x'), y, options

  updatePosition: (x, y, options) =>
    @moveTo x: x, y: y
    if options?.rebroadcast
      userIdentity = @model.board().userIdentityForId @model.get 'author'
      @dragLock.lock(1000, userIdentity.get('avatar'), userIdentity.get('displayName')) if userIdentity?

  updateOrder: (card, order, options) =>
    text = card.get('text')
    text = text.replace /\d+ - /, ''
    text = "#{order} - #{text}"
    @updateText card, text, options

  updateHover: (card, hover, options) =>
    @$el.removeClassMatching /hover-\w+/
    @$el.addClass "hover-#{hover}" if hover

  updateState: (card, state, options) =>
    previous = card.previous 'state'
    @$el.removeClass previous if previous
    @$el.addClass state if state

  updatePlusAuthors: (card, plusAuthors, options) =>
    return if plusAuthors.length == 0

    $plusCount = @$('.plus-count')
    $plusCount.text "+#{plusAuthors.length}"
    $plusCount.attr 'title', _.map(plusAuthors, (author) => _.escape(@model.board().userIdentityForId(author).displayName())).join(', ')

    $plusAuthors = @$('.plus-authors')
    $plusAuthors.empty()
    for plusAuthor in plusAuthors
      userIdentity = @model.board().userIdentityForId(plusAuthor)
      imgHTML = """
        <img class="avatar" src="#{userIdentity.get 'avatar'}" title="#{_.escape userIdentity.get 'displayName'}"/>
      """
      $plusAuthors.append(imgHTML)

    if plusAuthors.indexOf(@model.currentUserId()) > -1
        @$('.plus1 .btn').remove()

  updateAuthors: (card, authors, options) =>
    return if authors.length == 0

    $authors = @$('.authors')
    $authors.empty()
    for author in authors
      userIdentity = @model.board().userIdentityForId(author)
      imgHTML = """
        <img class="avatar" src="#{userIdentity.get 'avatar'}" title="#{_.escape userIdentity.get 'displayName'}"/>
      """
      $authors.append(imgHTML)

  updateILikeIWish: =>
    $textarea = @$el.find 'textarea'
    @$el.removeClass 'i-wish i-like'
    if matches = $textarea.val().match /^i (like|wish)/i
      @$el.addClass("i-#{matches[1]}")

  triggerAutosize: =>
    @$el.find('textarea').trigger 'autosize'

  focus: ->
    @$el.find('textarea').focus()
    @model.focus()

  # human interaction event handlers

  hiDelete: (event) ->
    @model.delete()

  hiChangeColor: (event) ->
    colorIndex = $(event.target).attr('class').match(/color-(\d+)/)[1]
    @model.colorize colorIndex

  hiChangeText: (event) ->
    @model.type @$('textarea').val()

  hiFocusText: (event) ->
    @model.focus()

  hiUnFocusText: (event) ->
    @model.unfocus()

  hiIncrementPlusCount: (event) ->
    @model.plusOne()
