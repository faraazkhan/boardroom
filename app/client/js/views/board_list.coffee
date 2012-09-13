class boardroom.views.BoardList extends Backbone.View
  el: '#boards'

  render: ->
    socket = io.connect '/channel/boards'
    for li in @$('ul li')
      new boardroom.views.BoardItem
        el: li
        socket: socket
