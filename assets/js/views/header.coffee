class boardroom.views.Header extends Backbone.View
  el: '#header'

  events:
    'keyup #title': 'updateBoardTitle'
    'click button.create': 'requestNewCard'

  initialize: (attributes) ->
    { @socket } = attributes
    @socket.on 'title_changed', @externalTitleUpdate

  externalTitleUpdate: (title) =>
    @$('#title').val title

  updateBoardTitle: (event) ->
    isEnter = event.keyCode is 13
    if isEnter
      @$('#title').blur()
    else
      @socket.emit 'title_changed', title: @$('#title').val()

  requestNewCard: ->
    @socket.emit 'add',
      boardId: @model.get('_id')
      author: @model.get('user_id')
      x: parseInt Math.random() * 700
      y: parseInt Math.random() * 400
      focus: true
