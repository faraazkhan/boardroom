class boardroom.views.Header extends Backbone.View
  el: '#header'

  events:
    'keyup #name': 'updateBoardName'

  initialize: (attributes) ->
    { @socket } = attributes
    @socket.on 'name_changed', @externalNameUpdate

  externalNameUpdate: (name) =>
    @$('#name').val name

  updateBoardName: (event) ->
    isEnter = event.keyCode is 13
    if isEnter
      @$('#name').blur()
    else
      @socket.emit 'name_changed', name: @$('#name').val()
