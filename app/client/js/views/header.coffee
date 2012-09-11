#= require './boardroom'

class boardroom.views.Header extends Backbone.View
  el: '#header'

  events:
    'keyup #title': 'updateBoardTitle'

  updateBoardTitle: (event) ->
    isEnter = event.keyCode is 13
    if isEnter
      @$('#title').blur()
    else
      @trigger 'title_changed', @$('#title').val()
