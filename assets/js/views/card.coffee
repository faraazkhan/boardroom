class boardroom.views.Card extends Backbone.View
  className: 'card'

  template: _.template("<img class='delete' src='/images/delete.png'/>
                        <div class='notice'></div>
                        <div class='colors'>
                          <span class='color color-0'></span>
                          <span class='color color-1'></span>
                          <span class='color color-2'></span>
                          <span class='color color-3'></span>
                          <span class='color color-4'></span>
                        </div>
                        <textarea><%= text %></textarea>
                        <div class='authors'></div>")

  attributes: ->
    id: @model.id

  events:
    'mousedown': 'updatePosition'
    'click .color': 'changeColor'
    'keyup textarea': 'changeText'
    'change textarea': 'commitText'
    'click .delete': 'delete'

  initialize: (attributes) ->
    { @socket } = attributes

    _.extend @, boardUtils @socket, @model

    @socket.on 'color', @updateColor
    @socket.on 'delete', @removeIfDeleted

  updatePosition: (event) ->
    isColorSelection = $(event.target).is 'span'
    isDeletion = $(event.target).is 'img'
    unless isColorSelection or isDeletion
      @card.onMouseDown event

  changeColor: (event) ->
    color = $(event.target)
      .attr('class')
      .match(/color-(\d+)/)[1]
    data =
      _id: @model.id
      colorIndex: color
    @socket.emit 'color', data
    @updateColor data

  setColor: (color) ->
    @$el.addClass "color-#{color}"

  uncolor: ->
    @$el.removeClassMatching /color-\d+/g

  updateColor: (data) =>
    if data._id is @model.id
      @uncolor()
      @setColor data.colorIndex

  changeText: ->
    @socket.emit 'text'
      _id: @model.id
      text: @$('textarea').val()
      author: @model.get('board').get('user_id')
    @addAuthor @model.get('board').get('user_id')
    @adjustTextarea()

  addAuthor: (user) ->
    avatar = boardroom.models.User.avatar user
    if @$(".authors img[title='#{user}']").length is 0
      @$('.authors').append("<img src='#{avatar}' title='#{_.escape user}'/>")

  adjustTextarea: ->
    $textarea = @$ 'textarea'
    $textarea.css 'height', 'auto'
    if $textarea.innerHeight() < $textarea[0].scrollHeight
      $textarea.css 'height', $textarea[0].textarea.scrollHeight + 14
    @analyzeText $textarea

  analyzeText: ($textarea) ->
    $card = $textarea.parents '.card'
    $card.removeClass 'i-wish i-like'
    if matches = $textarea.val().match /^i (like|wish)/i
      $card.addClass("i-#{matches[1]}")

  commitText: ->
    @socket.emit 'text_commit',
      _id: @model.id
      text: @$('textarea').val()
      board_name: @model.get('board').get('name')
      author: @model.get('board').get('user_id')
    if groupId = @$el.data('group-id')
      @group.layOut groupId

  delete: ->
    @socket.emit 'delete'
      _id: @model.id
      author: @model.get('board').get('user_id')

  removeIfDeleted: (data) =>
    if data._id is @model.id
      @remove()

  showNotice: ({ user, message }) =>
    if user?
      @$('.notice')
        .html("<img src='#{boardroom.models.User.avatar user}'/>
               <span>#{_.escape message}</span>")
        .show()
    else
      @$('.notice').show()

  disableEditing: (text) ->
    @$('textarea')
      .val(text)
      .attr 'disabled', 'disabled'

  moveTo: ({x, y}) ->
    @$el.css
      left: x
      top: y

  hideNotice: ->
    @$('.notice').fadeOut 100

  enableEditing: ->
    @$('textarea').removeAttr 'disabled'

  bringForward: ->
    @moveToTop @$el

  followDrag: ->
    @$el.followDrag
      onMouseMove: =>
        @socket.emit 'move',
          _id: @model.id
          x: @$el.position().left
          y: @$el.position().top
          board_name: @model.get('board').get('name')
          author: @model.get('board').get('user_id')

  render: ->
    @$el
      .html(@template(@model.toJSON()))
      .css
        left: @model.get('x')
        top: @model.get('y')
    @uncolor()
    @setColor @model.get('colorIndex') || 2
    @adjustTextarea()
    if @model.has('authors')
      for author in @model.get('authors')
        @addAuthor author
    if @model.has('groupId')
      @$el.data 'group-id', @model.get('groupId')
    if @model.get('focus')
      @$('textarea').focus()
    @
