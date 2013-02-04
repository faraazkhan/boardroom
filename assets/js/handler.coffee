class boardroom.Handler

  constructor: (@board, @user) ->

  initialize: () ->
    @socket = @createSocket()
    boardroom.socket  = @socket

    @socket.on 'connect', @onConnect
    @socket.on 'join', @onJoin
    @socket.on 'disconnect', @onDisconnect
    @socket.on 'reconnecting', @onReconnecting
    @socket.on 'reconnect', @onReconnect
    # client side events can collapse into standard BackBone Model and Collection operations:
    # load
    # reload
    # delete
    # add-item
    # remove-item

    #@socket.on 'Board.update', @onBoardUpdate
    #@socket.on 'Group.create', @onGroupCreate
    #@socket.on 'Group.update', @onGroupUpdate
    #@socket.on 'group.update-cards', @onGroupUpdateCards
    #@socket.on 'group.delete', @onGroupDelete
    #@socket.on 'card.update', @onCardUpdate
    #@socket.on 'Card.delete', @onCardDelete
    #@socket.on 'view.add-indicator', @onAddIndicator
    #@socket.on 'view.remove-indicator', @onRemoveIndicator

    # @board.on 'change', =>
    #   @send 'Board.update', @boardMessage()

    # groups = @board.get 'groups'
    # groups.on 'change', (group, options) =>
    #   unless options.synced?
    #     @send 'Group.update', @groupMessage(group, _(options.changes).keys())

    # pendingGroups = @board.get 'pendingGroups'
    # pendingGroups.on 'add', (group) =>
    #   @send 'Group.create', @groupMessage(group)
    #   pendingGroups.remove group

  createSocket: () ->
    io.connect "#{@socketHost()}/boards/#{@board.id}"

  # send: (name, message) ->
  #   console.log "send: #{name}"
  #   #console.log message
  #   @socket.emit name, message

  onConnect: =>
    console.log 'onConnect'
    @socket.emit 'join', @userMessage()
    # @send 'join', @userMessage()

  onDisconnect: =>
    console.log 'onDisconnect'
    @board.set 'status', 'Disconnected'

  onReconnecting: =>
    console.log 'onReconnecting'
    @board.set 'status', 'Reconnecting...'

  onReconnect: =>
    console.log 'onReconnect'
    @board.set 'status', null

  onJoin: (message) =>
    console.log 'onJoin'
    @board.addUser message

  onBoardUpdate: (message) =>
    console.log 'onBoardUpdate'
    @board.set 'name', message.name

  onGroupCreate: (message) =>
    console.log 'onGroupCreate'
    @board.get('groups').add(new boardroom.models.Group(message))

  onGroupUpdate: (message) =>
    console.log 'onGroupUpdate'
    @board.findGroup(message._id).set(_(message).omit('_id'), { synced: true })

  userMessage: () =>
    @user.toJSON()

  boardMessage: () =>
    _(@board.toJSON()).pick('_id', 'name')

  groupMessage: (group, attrs) =>
    message = group.toJSON()
    message = _(message).pick(attrs) if attrs?
    message._id = group.id if group.id
    message.boardId = @board.id unless message._id
    message.author = @board.get('user_id')
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
