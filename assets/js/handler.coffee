class boardroom.Handler

  constructor: (@board, @user) ->
    @logger = boardroom.utils.Logger.instance
    new boardroom.utils.Watcher(@board).watch()

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
    @socket.on 'group.delete', @onGroupDelete
    @socket.on 'card.create', @onCardCreate
    @socket.on 'card.update', @onCardUpdate
    @socket.on 'card.delete', @onCardDelete

    @board.on 'change', (board, options) =>
      @send 'board.update', @boardMessage(), options

    groups = @board.groups()

    handleCardEvents = (card, cards, options) =>
      unless card.eventsInitialized
        card.on 'change', (card, options) => @send 'card.update', @cardMessage(card), options
        card.on 'destroy', (card, cards, options) => @send 'card.delete', card.id, options
        card.eventsInitialized = true

    handleGroupEvents = (group) =>
      group.on 'change', (group, options) => @send 'group.update', @groupMessage(group), options
      group.on 'destroy', (group, groups, options) => @send 'group.delete', group.id, options

      cards = group.cards()
      cards.each handleCardEvents
      cards.on 'add', handleCardEvents

      pendingCards = group.get 'pendingCards'
      pendingCards.off 'add'
      pendingCards.on 'add', (card) =>
        @send 'card.create', @cardMessage(card)
        pendingCards.remove card

    groups.each handleGroupEvents
    groups.on 'add', handleGroupEvents
    groups.on 'add', (group) =>
      return if group.id?
      @send 'group.create', @groupMessage(group)

  createSocket: ->
    io.connect "#{@socketHost()}/boards/#{@board.id}"

  send: (name, message, options) =>
    return unless message?
    return if options?.rebroadcast

    logmsg = "send: #{name} - #{JSON.stringify(message)}"
    if name == 'card.update' or name == 'group.update'
      @logger.debug logmsg
    else
      @logger.info logmsg

    @socket.emit name, message

  onConnect: =>
    @logger.debug 'onConnect'
    @send 'join', @userMessage()

  onDisconnect: =>
    @logger.debug 'onDisconnect'
    @board.set 'status', 'Disconnected'

  onReconnecting: =>
    @logger.debug 'onReconnecting'
    @board.set 'status', 'Reconnecting...'

  onReconnect: =>
    @logger.debug 'onReconnect'
    @board.set 'status', null

  onJoin: (message) =>
    @logger.debug 'onJoin'
    @board.addUser message

  onBoardUpdate: (message) =>
    @logger.debug 'onBoardUpdate'
    @board.set 'name', message.name, { rebroadcast: true }

  onGroupCreate: (message) =>
    @logger.debug 'onGroupCreate'
    group = new boardroom.models.Group(message)
    existingGroup = @board.findGroupByCid message.cid
    if existingGroup?
      existingGroup.realize group
    else
      @board.groups().add(group, { rebroadcast: true })

  onGroupUpdate: (message) =>
    #@logger.debug 'onGroupUpdate'
    group = @board.findGroup message._id
    unless group
      @logger.debug "Handler: cannot find group #{message._id}"
      return
    group.set(_(message).omit('_id'), { rebroadcast: true })

  onGroupDelete: (message) =>
    @logger.debug 'onGroupDelete'
    group = @board.findGroup message
    unless group
      @logger.debug "Handler: cannot find group #{message}"
      return
    @board.get('groups').remove group, { rebroadcast: true }

  onCardCreate: (message) =>
    @logger.debug 'onCardCreate'
    group = @board.findGroup message.groupId
    group.get('cards').add(new boardroom.models.Card(message), { rebroadcast: true })

  onCardUpdate: (message) =>
    @logger.debug 'onCardUpdate'
    card = @board.findCard message._id
    unless card
      @logger.debug "Handler: cannot find card: #{message._id}"
      return
    card.set(_(message).omit('_id'), { rebroadcast: true })

  onCardDelete: (message) =>
    @logger.debug 'onCardDelete'
    card = @board.findCard message
    unless card
      @logger.debug "Handler: cannot find card #{message}"
      return
    card.get('group').get('cards').remove card, { rebroadcast: true }

  userMessage: () =>
    @user.toJSON()

  boardMessage: () =>
    _(@board.toJSON()).pick('_id', 'name')

  groupMessage: (group) =>
    attrs = _(group.changed).keys()
    message = group.toJSON()
    message = _(message).pick(attrs) if message._id # restrict to changed attrs on updates only
    message = _(message).omit('board', 'cards', 'pendingCards')
    return null if _(message).isEmpty()

    message._id = group.id if group.id?
    message.cid = group.cid
    message.boardId = @board.id unless message._id
    message.author = @board.currentUser()
    message

  cardMessage: (card) =>
    attrs = _(card.changed).keys()
    message = card.toJSON()
    message = _(message).pick(attrs) if message._id # restrict to changed attrs on updates only
    message = _(message).omit('group', 'board')
    return null if _(message).isEmpty()

    message._id = card.id if card.id?
    message.cid = card.cid
    message.author = @board.currentUser()
    message

  # We can dump this when nginx starts supporting websockets
  socketHost: ->
    loc = window.location
    if loc.hostname == 'boardroom.carbonfive.com'
      return 'http://boardroom.carbonfive.com:1337' if ( loc.port == '80' or loc.port == '' )
      return 'http://boardroom.carbonfive.com:1338' if loc.port == '81'
    ''
