class boardroom.views.Header extends boardroom.views.Base
  el: '#board-nav'

  events:
    'keyup #name': 'hiChangeBoardName'

  initialize: (attributes) ->
    super attributes
    @initializeLock()
    @$('#name').trimInput(80)

    @model.on 'change:name', @onBoardUpdate, @

  initializeLock: =>
    @editLock = @createEditLock '#name'

  ###
      human interaction event handlers
  ###

  hiChangeBoardName: (event) =>
    isEnter = event.keyCode is 13
    if isEnter
      @$('#name').blur()
    else
      @model.set 'name', @$('#name').val()

  ###
      model handlers
  ###

  onBoardUpdate: (board, name, options) =>
    @$('#name').val(name).trimInput(80)
    if options?.rebroadcast
      @editLock.lock 1000
