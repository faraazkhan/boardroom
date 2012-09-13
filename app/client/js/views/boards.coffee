class boardroom.views.Boards extends Backbone.View
  el: '#boards'

  render: ->
    for li in @$('ul li')
      new boardroom.views.BoardItem el: li
