class boardroom.views.Card extends boardroom.views.Base
  className: 'card'
  template: _.template """
    <div class='header-bar'>
      <span class='delete-btn'>&times;</span>
      <span class='notice'></span>
      <div class='plus-authors'></div>
    </div>
    <textarea><%= text %></textarea>
    <div class='footer'>
      <div class='plus-count'></div>
      <div class='toolbar'>
        <div class='plus1'>
          <a class='btn' href='#'>+1</a>
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
    'click .color': 'hiChangeColor'
    'keyup textarea': 'hiChangeText'
    'click textarea': 'hiFocusText'
    'click .plus1 .btn': 'hiIncrementPlusCount'
    'click .delete-btn': 'hiDeleteMe'

  initialize: (attributes) ->
    { @groupView, @boardView } = attributes
    super attributes
    @initializeDraggable()

  onLockPoll: ()=>
    @enableEditing 'textarea'

  initializeSourcePath: ()->
    @sourcePath =
      boardId: @boardView.model.id
      groupId: @groupView.model.id
      cardId: @model.id

  initializeDraggable: ->
    @$el.draggable
      minX: @boardView.left() + 12
      minY: @boardView.top()  + 12
      isTarget: (target) =>
        # return false if $(target).is 'input'
        # return false if $(target).is '.color'
        return false if $(target).is '.delete'
        true
      isOkToDrag: () => 
        # dont allow card to drag if its the only one in its group (allow the group to drag)
        1 < @groupView.cardCount()
      onMouseDown: =>
        @groupView.bringForward()
        z = @bringForward()
        @socket.emit 'card.update', { _id: @model.id, z }
      onMouseMove: =>
        @emitMove()
      onMouseUp: =>
        nothingToDropOnto = => @moveBackToRestingSpot() if (@$el? and @$el.is(':visible'))
        setTimeout nothingToDropOnto, 350 # move back if nothing picks up the drop
      startedDragging:()=>
        @$el.addClass('dragging')
      stoppedDragging: ()=>
        @$el.removeClass('dragging')

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
    @setColor @model.get('colorIndex')
    if @model.has('authors')
      for author in @model.get('authors')
        @addAuthor author
    if @model.has('plusAuthors')
      for plusAuthor in @model.get('plusAuthors')
        @addPlusAuthor plusAuthor
    if @model.get('focus')
      @$('textarea').focus()
    @

  update: (data) =>
    if data.x?
      @moveTo x: data.x, y: data.y
      @showNotice user: data.author, message: data.author
      @authorLock.lock 500
    if data.z?
      @groupView.bringForward() if data.z > @$el.css 'z-index'
      @$el.css 'z-index', data.z
    if data.text?
      @disableEditing 'textarea', data.text
      @showNotice user: data.author, message: "#{data.author} is typing..."
      @authorLock.lock()
      @addAuthor data.author
      @adjustTextarea()
    if data.colorIndex?
      @addAuthor data.author
      @setColor data.colorIndex
    if data.plusAuthor?
      @addPlusAuthor data.plusAuthor

  setColor: (color) ->
    color = 2 if color == undefined
    @$el.removeClassMatching /color-\d+/g
    @$el.addClass "color-#{color}"

  addPlusAuthor: (author) ->
    avatar = boardroom.models.User.avatar author
    if @$(".plus-authors img[title='#{user}']").length is 0
      user = @model.get('board').get('user_id')
      $plusCount = @$('.plus-count')
      $plusAuthors = @$('.plus-authors')
      plusCountValue = parseInt($plusCount.text()) || 0

      $plusCount.text("+#{plusCountValue+1}")
      $plusAuthors.append("<img class='avatar' src='#{avatar}' title='#{_.escape author}'/>")

      plusAuthors = []
      for avatar in $plusAuthors.find('img')
        plusAuthors.push $(avatar).attr('title')
      $plusCount.attr('title', plusAuthors.join(', '))

      if author == user
        @$('.plus1 .btn').remove()

  addAuthor: (user) ->
    avatar = boardroom.models.User.avatar user
    if @$(".authors img[title='#{user}']").length is 0
      @$('.authors').append("<img class='avatar' src='#{avatar}' title='#{_.escape user}'/>")

  adjustTextarea: ->
    $textarea = @$ 'textarea'
    $textarea.autosize()
    @analyzeText $textarea

  analyzeText: ($textarea) ->
    $card = $textarea.parents '.card'
    $card.removeClass 'i-wish i-like'
    if matches = $textarea.val().match /^i (like|wish)/i
      $card.addClass("i-#{matches[1]}")


  ###
      human interaction event handlers
  ###

  hiChangeColor: (event) ->
    event.stopPropagation()
    colorIndex = $(event.target).attr('class').match(/color-(\d+)/)[1]
    author = @model.get('board').get('user_id')
    @setColor colorIndex
    @addAuthor author
    z = @bringForward()
    @socket.emit 'card.update', { _id: @model.id, colorIndex, z, author }

  hiChangeText: (e)->
    text = @$('textarea').val()
    existing = @model.get 'text'
    @model.set 'text', text
    if text != existing
      author = @model.get('board').get('user_id')
      @addAuthor author
      @adjustTextarea()
      z = @bringForward()
      @socket.emit 'card.update', { _id: @model.id, text, z, author }

  hiFocusText: (event)->
    z = @bringForward()
    @socket.emit 'card.update', { _id: @model.id, z}
    @$('textarea').focus()

  hiIncrementPlusCount: (e) ->
    e.stopPropagation()
    e.preventDefault()
    plusAuthor = @model.get('board').get('user_id')
    @addPlusAuthor plusAuthor
    z = @bringForward()
    @socket.emit 'card.update', { _id: @model.id, plusAuthor, z }

  hiDropOnToGroup: (event, parentGroupView) ->
    event.stopPropagation()
    if parentGroupView is @groupView
      @moveBackToRestingSpot()
      return
    @eventsOff()
    @groupView.eventsOff() if @groupView.cardViews.length is 1
    @boardView.switchGroups @sourcePath, parentGroupView.sourcePath

  hiDropOnToBoard: (event, boardView) ->
    event.stopPropagation()
    @eventsOff()
    @groupView.eventsOff() if @groupView.cardViews.length is 1
    @boardView.ungroupCard @sourcePath, @coordinateInBoard()
    # @boardView.createNewGroup @coordinateInContainer(boardView)
    # @deleteMe()

