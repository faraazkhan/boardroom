class boardroom.Handler

  constructor: (@board) ->
    @socket = io.connect "#{@socketHost()}/boards/#{@board.id}"

    @socket.on 'joined', @onJoined
    @socket.on 'connect', @onConnect
    @socket.on 'disconnect', @onDisconnect
    @socket.on 'reconnecting', @onReconnecting
    @socket.on 'reconnect', @onReconnect
    @socket.on 'board.update', @onBoardUpdate
    @socket.on 'group.create', @onGroupCreate
    @socket.on 'group.update', @onGroupUpdate
    @socket.on 'group.update-cards', @onGroupUpdateCards
    @socket.on 'group.delete', @onGroupDelete
    @socket.on 'card.update', @onCardUpdate
    @socket.on 'card.delete', @onCardDelete
    @socket.on 'view.add-indicator', @onAddIndicator
    @socket.on 'view.remove-indicator', @onRemoveIndicator

    @board.on 'change', =>
      @send 'board.update', @boardMessage(@board)

  send: (name, message) ->
    console.log name
    console.log message
    @socket.emit name, message

  onBoardUpdate: (data) =>
    @board.set 'name', data.name

  onGroupCreate: (data) ->
    findGroup(data).displayNewGroup data

  boardMessage: (board) ->
    attrs = _.pick board.toJSON(), 'name'
    attrs._id = board.id
    attrs

  findCard: (data) ->
    @board.findCard data._id

  findGroup: (data) ->
    @board.findGroup data._id

  # We can dump this when nginx starts supporting websockets
  socketHost: ->
    loc = window.location
    if loc.hostname == 'boardroom.carbonfive.com'
      return 'http://boardroom.carbonfive.com:1337' if ( loc.port == '80' or loc.port == '' )
      return 'http://boardroom.carbonfive.com:1338' if loc.port == '81'
    ''
