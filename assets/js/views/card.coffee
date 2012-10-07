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
    'click .delete': 'delete'

  initialize: (attributes) ->
    { @socket } = attributes
    _.extend @, boardUtils @socket, @model
    @socket.on 'card.delete', @removeIfDeleted
    @cardLock = new boardroom.models.CardLock
    @cardLock.poll =>
      @hideNotice()
      @enableEditing()

  update: (data) =>
    if data.x?
      @moveTo x: data.x, y: data.y
      @showNotice user: data.author, message: data.author
      @cardLock.lock 500
      @bringForward()
    if data.text?
      @disableEditing data.text
      @showNotice user: data.author, message: "#{data.author} is typing..."
      @cardLock.lock()
      @addAuthor data.author
      @adjustTextarea()
      @bringForward()
    if data.colorIndex?
      @setColor data.colorIndex

  updatePosition: (event) ->
    isColorSelection = $(event.target).is '.color'
    isDeletion = $(event.target).is '.delete'
    unless isColorSelection or isDeletion
      @card.onMouseDown event

  changeColor: (event) ->
    color = $(event.target)
      .attr('class')
      .match(/color-(\d+)/)[1]
    data =
      _id: @model.id
      colorIndex: color
    @socket.emit 'card.update', data
    @setColor data.colorIndex

  setColor: (color) ->
    color = 2 if color == undefined
    @$el.removeClassMatching /color-\d+/g
    @$el.addClass "color-#{color}"

  changeText: ->
    @socket.emit 'card.update'
      _id: @model.id
      text: @$('textarea').val()
      author: @model.get('board').get('user_id')
    @addAuthor @model.get('board').get('user_id')
    @adjustTextarea()

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

  delete: ->
    @socket.emit 'card.delete', @model.id

  removeIfDeleted: (id) =>
    if id is @model.id
      @remove()

  showNotice: ({ user, message }) =>
    if user?
      @$('.notice')
        .html("<img class='avatar' src='#{boardroom.models.User.avatar user}'/>
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
    @setColor @model.get('colorIndex')
    if @model.has('authors')
      for author in @model.get('authors')
        @addAuthor author
    if @model.has('groupId')
      @$el.data 'group-id', @model.get('groupId')
    if @model.get('focus')
      @$('textarea').focus()
    @
