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
    onLock = (user, message) => @disableEditing('#name')
    onUnlock = => @enableEditing('#name')
    @lock = new boardroom.models.Lock onLock, onUnlock

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
      @lock.lock 1000
