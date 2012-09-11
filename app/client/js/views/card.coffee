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
    'mousedown': 'updateCardPosition'
    'click .color': 'updateColor'
    'keyup textarea': 'textChange'
    'change textarea': 'textCommit'
    'click .delete': 'cardDeleted'

  initialize: (attributes) ->
    { @boardroom, @socket } = attributes

  updateCardPosition: (event) ->
    unless $(event.target).is('span')
      @boardroom.card.onMouseDown event

  updateColor: (event) ->
    $colorElement = $ event.target
    card = $colorElement.closest('.card')[0]
    colorIndex = $colorElement.attr('class').match(/color-(\d+)/)[1]
    data =
      _id: @model.id
      colorIndex: colorIndex
    @socket.emit 'color', data
    @toggleColorClass data

  toggleColorClass: (data) ->
    @$el.removeClassMatching /color-\d+/g
    @$el.addClass "color-#{data.colorIndex}"

  textChange: (event) =>
    $cardElement = $ event.target
    card = $cardElement.closest('.card')[0]
    @socket.emit 'text'
      _id: card.id
      text: $cardElement.val()
      author: @model.user_id
    @addAuthor @model.get('board').get('user_id')
    @adjustTextarea $cardElement

  addAuthor: (author) =>
    avatar = boardroom.models.User.avatar author
    if @$(".authors img[title='#{author}']").length is 0
      @$('.authors').append("<img src='#{avatar}' title='#{_.escape author}'/>")

  adjustTextarea: ($textarea) ->
    $textarea.css 'height', 'auto'
    if $textarea.innerHeight() < $textarea[0].scrollHeight
      $textarea.css 'height', $textarea[0].textarea.scrollHeight + 14
    @analyzeCardContent $textarea

  analyzeCardContent: ($textarea) ->
    $card = $textarea.parents '.card'
    $card.removeClass 'i-wish i-like'
    if matches = $textarea.val().match /^i (like|wish)/i
      $card.addClass("i-#{matches[1]}")

  textCommit: (event) =>
    $cardElement = $ event.target
    card = $cardElement.closest('.card')[0]
    @socket.emit 'text_commit',
      _id: card.id
      text: $cardElement.val()
      board_name: @model.get('board').get('name')
      author: @model.get('board').get('user_id')
    if groupId = $(card).data('group-id')
      @boardroom.group.layOut(groupId)

  cardDeleted: (event) =>
    card = $(event.target).closest('.card')[0]
    @socket.emit 'delete'
      _id: card.id
      author: @model.get('board').get('user_id')
    $(card).remove()

  render: ->
    @$el
      .html(@template @model.toJSON())
      .css(left: @model.get('x'),
           top: @model.get('y'))
      .removeClassMatching(/color-\d+/g)
      .addClass "color-#{@model.get('colorIndex') || 2}"
    @adjustTextarea $('textarea', @$el)
    if @model.has('authors')
      for author in @model.get('authors')
        @addAuthor author
    if @model.has 'groupId'
      @$el.data 'group-id', @model.get('groupId')
    @
