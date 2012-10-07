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
    'click .color': 'changeColor'
    'keyup textarea': 'changeText'
    'click .delete': 'delete'

  initialize: (attributes) ->
    { @socket } = attributes
    _.extend @, boardUtils @socket, @model
    @followDrag()
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

  changeColor: (event) ->
    colorIndex = $(event.target).attr('class').match(/color-(\d+)/)[1]
    author = @model.get('board').get('user_id')
    @setColor colorIndex
    @addAuthor author
    @socket.emit 'card.update', { _id: @model.id, colorIndex, author }

  changeText: ->
    text = @$('textarea').val()
    author = @model.get('board').get('user_id')
    @addAuthor author
    @adjustTextarea()
    @socket.emit 'card.update', { _id: @model.id, text, author }

  delete: ->
    @socket.emit 'card.delete', @model.id

  setColor: (color) ->
    color = 2 if color == undefined
    @$el.removeClassMatching /color-\d+/g
    @$el.addClass "color-#{color}"

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

  bringForward: ->
    @moveToTop @$el

  followDrag: ->
    @$el.followDrag
      isTarget: (target) ->
        return false if $(target).is 'textarea'
        return false if $(target).is 'color'
        return false if $(target).is 'delete'
        true
      onMouseMove: =>
        @socket.emit 'card.update',
          _id: @model.id
          x: @$el.position().left
          y: @$el.position().top
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
    if @model.get('focus')
      @$('textarea').focus()
    @
