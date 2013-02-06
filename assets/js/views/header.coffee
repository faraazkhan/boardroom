class boardroom.views.Header extends Backbone.View
  el: '#board-nav'

  events:
    'keyup #name': 'hiChangeBoardName'

  initialize: (attributes) ->
    { @socket } = attributes
    @socket.on 'board.update', @onBoardUpdate

    @$('#name').trimInput(80)

  ###
      human interaction event handlers
  ###

  hiChangeBoardName: (event) ->
    isEnter = event.keyCode is 13
    if isEnter
      @$('#name').blur()
    else
      @socket.emit 'board.update', _id: @model.get('_id'), name: @$('#name').val()

    ###
        socket handlers
    ###

  onBoardUpdate: (data) =>
    @$('#name').val(data.name).trimInput(80)


