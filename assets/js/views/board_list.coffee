class boardroom.views.BoardList extends Backbone.View
  el: '#boards'

  initialize: ->
    @boardItems = []

  render: ->
    for li in @$('ul li')
      boardItem = new boardroom.views.BoardItem
        el: li
      @boardItems.push boardItem
