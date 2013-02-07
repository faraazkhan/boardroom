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
    @socket.on 'group.update', @onGroupUpdate
    #@socket.on 'group.update-cards', @onGroupUpdateCards
    @socket.on 'group.delete', @onGroupDelete
    @socket.on 'card.update', @onCardUpdate
    @socket.on 'card.delete', @onCardDelete
    #@socket.on 'view.add-indicator', @onAddIndicator
    #@socket.on 'view.remove-indicator', @onRemoveIndicator

    @board.on 'change', (board, options) =>
      unless options.rebroadcast?
        @send 'board.update', @boardMessage()

    groups = @board.get 'groups'
    groups.on 'change', (group, options) =>
      unless options.rebroadcast?
        @send 'group.update', @groupMessage(group, _(options.changes).keys())

    groups.on 'remove', (group, groups, options) =>
      unless options.rebroadcast?
        @send 'group.delete', group.id

    onCardEvents = (group) =>
      cards = group.get 'cards'
      cards.on 'change', (card, options) =>
        unless options.rebroadcast?
          @send 'card.update', @cardMessage(card, _(options.changes).keys())
      cards.each (card) =>
        card.on 'destroy', (card, cards, options) =>
          unless options.rebroadcast?
            @send 'card.delete', card.id

    groups.each (group) => onCardEvents(group)
    groups.on 'add', onCardEvents # new groups need to handle these events too

    pendingGroups = @board.get 'pendingGroups'
    pendingGroups.on 'add', (group) =>
      @send 'group.create', @groupMessage(group)
      pendingGroups.remove group

  createSocket: () ->
    io.connect "#{@socketHost()}/boards/#{@board.id}"

  send: (name, message) ->
    return unless message?
    unless name == 'group.update'
      console.log "send: #{name}"
      console.log message
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

  onJoin: (message) =>
    console.log 'onJoin'
    @board.addUser message

  onBoardUpdate: (message) =>
    console.log 'onBoardUpdate'
    @board.set 'name', message.name, { rebroadcast: true }

  onGroupCreate: (message) =>
    console.log 'onGroupCreate'
    @board.get('groups').add(new boardroom.models.Group(message), { rebroadcast: true })

  onGroupUpdate: (message) =>
    #console.log 'onGroupUpdate'
    group = @board.findGroup message._id
    unless group
      console.log "Handler: cannot find group #{message._id}"
      return
    group.set(_(message).omit('_id'), { rebroadcast: true })

  onGroupDelete: (message) =>
    console.log 'onGroupDelete'
    group = @board.findGroup message
    unless group
      console.log "Handler: cannot find group #{message}"
      return
    @board.get('groups').remove group, { rebroadcast: true }

  onCardUpdate: (message) =>
    console.log 'onCardUpdate'
    card = @board.findCard message._id
    unless card
      console.log "Handler: cannot find card: #{message._id}"
      return
    card.set(_(message).omit('_id'), { rebroadcast: true })

  onCardDelete: (message) =>
    console.log 'onCardDelete'
    card = @board.findCard message
    unless card
      console.log "Handler: cannot find card #{message}"
      return
    card.get('group').get('cards').remove card, { rebroadcast: true }

  userMessage: () =>
    @user.toJSON()

  boardMessage: () =>
    _(@board.toJSON()).pick('_id', 'name')

  groupMessage: (group, attrs) =>
    message = group.toJSON()
    message = _(message).pick(attrs) if attrs?
    message = _(message).omit('board')
    return null if _(message).isEmpty()

    message._id = group.id if group.id?
    message.boardId = @board.id unless message._id
    message.author = @board.get 'user_id'
    message

  cardMessage: (card, attrs) =>
    message = card.toJSON()
    message = _(message).pick(attrs) if attrs?
    message = _(message).omit('group', 'board')
    return null if _(message).isEmpty()

    message._id = card.id if card.id?
    message.author = @board.get 'user_id'
    message

  # We can dump this when nginx starts supporting websockets
  socketHost: ->
    loc = window.location
    if loc.hostname == 'boardroom.carbonfive.com'
      return 'http://boardroom.carbonfive.com:1337' if ( loc.port == '80' or loc.port == '' )
      return 'http://boardroom.carbonfive.com:1338' if loc.port == '81'
    ''
