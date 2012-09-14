class boardroom.views.BoardList extends Backbone.View
  el: '#boards'

  initialize: ->
    @boardItems = []

  render: ->
    socket = io.connect '/channel/boards'
    for li in @$('ul li')
      boardItem = new boardroom.views.BoardItem
        el: li
        socket: socket
      @boardItems.push boardItem
