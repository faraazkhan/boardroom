class boardroom.views.Card extends Backbone.View
  className: 'card'

  template: _.template("<span class='delete'>&times;</span>
                        <div class='notice'></div>
                        <div class='plus-authors'></div>
                        <div class='toolbar'>
                          <div class='plus1'>
                            <a class='btn' href='#'>+1</a>
                            <span class='plus-count'></span>
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
                        <textarea><%= text %></textarea>
                        ")

  attributes: ->
    id: @model.id

  events:
    'click .color': 'changeColor'
    'keyup textarea': 'changeText'
    'click textarea': 'focusText'
    'click .plus1 .btn': 'incrementPlusCount'
    'click .delete': 'delete'

  initialize: (attributes) ->
    { @socket } = attributes
    @$el.data 'view', @
    @initializeDraggable()
    @initializeDroppable()
    @cardLock = new boardroom.models.CardLock
    @cardLock.poll =>
      @hideNotice()
      @enableEditing()

  update: (data) =>
    if data.x?
      @moveTo x: data.x, y: data.y
      @showNotice user: data.author, message: data.author
      @cardLock.lock 500
    if data.z?
      @$el.css 'z-index', data.z
    if data.text?
      @disableEditing data.text
      @showNotice user: data.author, message: "#{data.author} is typing..."
      @cardLock.lock()
      @addAuthor data.author
      @adjustTextarea()
    if data.colorIndex?
      @addAuthor data.author
      @setColor data.colorIndex
    if data.plusAuthor?
      @addPlusAuthor data.plusAuthor

  changeColor: (event) ->
    colorIndex = $(event.target).attr('class').match(/color-(\d+)/)[1]
    author = @model.get('board').get('user_id')
    @setColor colorIndex
    @addAuthor author
    z = @bringForward()
    @socket.emit 'card.update', { _id: @model.id, colorIndex, z, author }

  changeText: ->
    text = @$('textarea').val()
    author = @model.get('board').get('user_id')
    @addAuthor author
    @adjustTextarea()
    z = @bringForward()
    @socket.emit 'card.update', { _id: @model.id, text, z, author }

  focusText: ->
    z = @bringForward()
    @socket.emit 'card.update', { _id: @model.id, z}

  incrementPlusCount: (e) ->
    e.preventDefault()
    plusAuthor = @model.get('board').get('user_id')
    @addPlusAuthor plusAuthor
    z = @bringForward()
    @socket.emit 'card.update', { _id: @model.id, plusAuthor, z }

  delete: ->
    @socket.emit 'card.delete', @model.id

  setColor: (color) ->
    color = 2 if color == undefined
    @$el.removeClassMatching /color-\d+/g
    @$el.addClass "color-#{color}"

  addPlusAuthor: (author) ->
    avatar = boardroom.models.User.avatar author
    if @$(".plus-authors img[title='#{user}']").length is 0
      user = @model.get('board').get('user_id')
      $plusCount = @$('.plus1 .plus-count')
      $plusAuthors = @$('.plus-authors')
      plusCountValue = parseInt($plusCount.text()) || 0

      $plusCount.text("+#{plusCountValue+1}")
      $plusAuthors.append("<img class='avatar' src='#{avatar}' title='#{_.escape user}'/>")

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
    $textarea.css 'height', 'auto'
    if $textarea.innerHeight() < $textarea[0].scrollHeight
      $textarea.css 'height', $textarea[0].scrollHeight + 14
    @analyzeText $textarea

  analyzeText: ($textarea) ->
    $card = $textarea.parents '.card'
    $card.removeClass 'i-wish i-like'
    if matches = $textarea.val().match /^i (like|wish)/i
      $card.addClass("i-#{matches[1]}")

  showNotice: ({ user, message }) =>
    @$('.notice')
      .html("<img class='avatar' src='#{boardroom.models.User.avatar user}'/><span>#{_.escape message}</span>")
      .show()

  enableEditing: ->
    @$('textarea').removeAttr 'disabled'

  disableEditing: (text) ->
    @$('textarea').val(text).attr('disabled', 'disabled')

  moveTo: ({x, y}) ->
    @$el.css { left: x, top: y }

  hideNotice: ->
    @$('.notice').fadeOut 100

  zIndex: ->
    parseInt(@$el.css('z-index')) || 0

  left: ->
    @$el.position().left

  top: ->
    @$el.position().top

  bringForward: ->
    siblings = @$el.siblings '.card'
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
        @socket.emit 'card.update', { _id: @model.id, z }
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
        $(target).data('view').snapTo @el
        @$el.removeClass 'stackable'

  snapTo: (target) ->
    pos = $(target).position()
    @moveTo x: pos.left + 10, y: pos.top + 20
    @emitMove()

  emitMove: () ->
    @socket.emit 'card.update',
      _id: @model.id
      x: @left()
      y: @top()
      author: @model.get('board').get('user_id')

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
