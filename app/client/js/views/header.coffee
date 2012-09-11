class boardroom.views.Header extends Backbone.View
  el: '#header'

  events:
    'keyup #title': 'updateBoardTitle'
    'click button.create': 'createCard'

  initialize: (attributes) ->
    { @socket } = attributes

  updateBoardTitle: (event) ->
    isEnter = event.keyCode is 13
    if isEnter
      @$('#title').blur()
    else
      @socket.emit 'title_changed', @$('#title').val()

  createCard: ->
    @socket.emit 'add',
      boardName: @model.name
      author: @model.user_id
      x: parseInt Math.random() * 700
      y: parseInt Math.random() * 400

