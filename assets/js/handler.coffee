class boardroom.Handler

  constructor: (@board, @user) ->

  initialize: () ->
    @socket = @createSocket()

    @socket.on 'connect', @onConnect
    @socket.on 'join', @onJoin
    @socket.on 'disconnect', @onDisconnect
    @socket.on 'reconnecting', @onReconnecting
    @socket.on 'reconnect', @onReconnect
    @socket.on 'board.update', @onBoardUpdate
    @socket.on 'group.create', @onGroupCreate
    #@socket.on 'group.update', @onGroupUpdate
    #@socket.on 'group.update-cards', @onGroupUpdateCards
    #@socket.on 'group.delete', @onGroupDelete
    #@socket.on 'card.update', @onCardUpdate
    #@socket.on 'card.delete', @onCardDelete
    #@socket.on 'view.add-indicator', @onAddIndicator
    #@socket.on 'view.remove-indicator', @onRemoveIndicator

    @board.on 'change', =>
      @send 'board.update', @boardMessage()

    pendingGroups = @board.get 'pendingGroups'
    pendingGroups.on 'add', (group) =>
      @send 'group.create', @groupMessage(group)
      pendingGroups.remove group

  createSocket: () ->
    io.connect "#{@socketHost()}/boards/#{@board.id}"

  send: (name, message) ->
    console.log "send: #{name}"
    #console.log message
    @socket.emit name, message

  onConnect: =>
    console.log 'onConnect'
    @send 'join', @userMessage()

  onDisconnect: =>
    console.log 'onDisconnect'
    @board.set 'status', 'Disconnected'

  onReconnecting: =>
    console.log 'onReconnecting'
    @board.set 'status', 'Reconnecting...'

  onReconnect: =>
    console.log 'onReconnect'
    @board.set 'status', null

  onJoin: (data) =>
    console.log 'onJoin'
    @board.addUser data

  onBoardUpdate: (data) =>
    console.log 'onBoardUpdate'
    @board.set 'name', data.name

  onGroupCreate: (data) =>
    console.log 'onGroupCreate'
    @board.get('groups').add(new boardroom.models.Group(data))

  userMessage: () =>
    @user.toJSON()

  boardMessage: () =>
    _.chain(@board.toJSON()).pick('name').extend({ _id: @board.id }).value()

  groupMessage: (group) =>
    message = group.toJSON()
    message._id = group.id if group.id
    message.boardId = @board.id
    message

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
