class boardroom.views.BoardList extends Backbone.View
  el: '#boards'

  render: ->
    for li in @$('ul li')
      new boardroom.views.BoardItem el: li
