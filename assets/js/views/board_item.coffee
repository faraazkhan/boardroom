class boardroom.views.BoardItem extends Backbone.View
  events:
    'click .delete': 'deleteBoard'

  initialize: (attributes) ->
    { @socket } = attributes
    @id = @$el.attr 'id'
    @socket.on 'delete', @removeBoard

  deleteBoard: (event) ->
    event.preventDefault()
    $element = $ event.target
    if $element.hasClass('confirm')
      @socket.emit 'delete', id: @id
      @$('.message').hide()
      @$el.slideUp()
    else
      $element.addClass('confirm')

  removeBoard: (data) =>
    if data.id is @id
      @$el.height @$el.height()
      @$el
        .empty()
        .append($('<p>This board has been deleted.</p>'))
        .delay(2000)
        .slideUp()
