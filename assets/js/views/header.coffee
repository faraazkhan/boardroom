class boardroom.views.Header extends Backbone.View
  el: '#board-nav'

  events:
    'keyup #name': 'hiChangeBoardName'

  initialize: (attributes) ->
    @model.on 'change:name', @onBoardUpdate, @
    @$('#name').trimInput(80)

  ###
      human interaction event handlers
  ###

  hiChangeBoardName: (event) ->
    isEnter = event.keyCode is 13
    if isEnter
      @$('#name').blur()
    else
      @model.set 'name', @$('#name').val()

  ###
      model handlers
  ###

  onBoardUpdate: (model, value) =>
    @$('#name').val(value).trimInput(80)
