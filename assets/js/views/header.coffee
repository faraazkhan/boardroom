class boardroom.views.Header extends Backbone.View
  el: '#header'

  events:
    'keyup #name': 'changeBoardName'

  initialize: (attributes) ->
    @headerView = new boardroom.views.Draw
    { @socket } = attributes
    @socket.on 'board.update', @onBoardUpdate

  changeBoardName: (event) ->
    isEnter = event.keyCode is 13
    if isEnter
      @$('#name').blur()
    else
      @socket.emit 'board.update', _id: @model.get('_id'), name: @$('#name').val()

  onBoardUpdate: (data) =>
    @$('#name').val data.name
