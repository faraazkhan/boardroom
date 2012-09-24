class boardroom.views.Header extends Backbone.View
  el: '#header'

  events:
    'keyup #name': 'updateBoardName'
    'click button.create': 'requestNewCard'

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

  requestNewCard: ->
    @socket.emit 'add',
      boardId: @model.get('_id')
      author: @model.get('user_id')
      x: parseInt Math.random() * 700
      y: parseInt Math.random() * 400
      focus: true
