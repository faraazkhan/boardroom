class boardroom.Handler

  constructor: (@namespace, @board) ->
    @metrics = new boardroom.utils.Metrics @board
    @user = @board.currentUser()
    @logger = boardroom.utils.Logger.instance
    @logger.user = @user

  initialize: () ->
    @socket = @createSocket()
    @logger.socket = @socket
    new boardroom.utils.Watcher(@user, @board, @socket).watch()

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

    $(window).on 'beforeunload', => # don't show disconnect status for user initiated page reload
      @socket.removeListener 'disconnect', @onDisconnect
      @socket.removeListener 'reconnecting', @onReconnecting
      @socket.removeListener 'reconnect', @onReconnect
      undefined # avoids popup confirmation for leaving page

    @board.on 'change', (board, options) =>
      @send 'board.update', @boardMessage(), options

    groups = @board.groups()

    handleCardEvents = (card, cards, options) =>
      unless card.eventsInitialized
        card.on 'change', (card, options) => @send 'card.update', @cardMessage(card), options
        card.on 'destroy', (card, cards, options) => @send 'card.delete', @deleteMessage(card), options
        card.eventsInitialized = true

    handleGroupEvents = (group) =>
      group.on 'change', (group, options) => @send 'group.update', @groupMessage(group), options
      group.on 'destroy', (group, groups, options) => @send 'group.delete', @deleteMessage(group), options

      cards = group.cards()
      cards.each handleCardEvents
      cards.on 'add', handleCardEvents
      cards.on 'add', (card) =>
        return if card.id?
        @send 'card.create', @cardMessage(card)

    groups.each handleGroupEvents
    groups.on 'add', handleGroupEvents
    groups.on 'add', (group) =>
      return if group.id?
      @send 'group.create', @groupMessage(group)

  createSocket: =>
    io.connect @namespace

  send: (name, message, options) =>
    return unless message?
    return if options?.rebroadcast

    logmsg = "send: #{name} - #{JSON.stringify(message)}"
    if name == 'card.update' or name == 'group.update'
      @logger.debug logmsg
    else
      @logger.info logmsg

    @metrics.track name, message
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
    # @board.set 'status', null
    # this is a hack, but i can't get socket.io reconnect to work
    window.location.reload()
    # @send 'join', @userMessage()

  onJoin: (message) =>
    @logger.debug 'onJoin'
    @board.setOnlineUsers message.users
    @board.userJoined message.userId

  onBoardUpdate: (message) =>
    @logger.debug 'onBoardUpdate'
    @board.set 'name', message.name, { rebroadcast: true }

  onGroupCreate: (message) =>
    @logger.debug 'onGroupCreate'
    group = new boardroom.models.Group message
    existingGroup = @board.findGroupByCid message.cid
    if existingGroup? and existingGroup.id == undefined
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
    group = @board.findGroup message._id
    unless group
      @logger.debug "Handler: cannot find group #{message._id}"
      return
    @board.get('groups').remove group, { rebroadcast: true }

  onCardCreate: (message) =>
    @logger.debug 'onCardCreate'
    group = @board.findGroup message.groupId
    card = new boardroom.models.Card message
    card.set 'group', group, { silent: true }
    existingCard = group.findCardByCid message.cid
    if existingCard? and existingCard.id == undefined
      existingCard.realize card
    else
      group.cards().add(card, { rebroadcast: true })

  onCardUpdate: (message) =>
    @logger.debug 'onCardUpdate'
    card = @board.findCard message._id
    unless card
      @logger.debug "Handler: cannot find card: #{message._id}"
      return
    card.set(_(message).omit('_id'), { rebroadcast: true })

  onCardDelete: (message) =>
    @logger.debug 'onCardDelete'
    card = @board.findCard message._id
    unless card
      @logger.debug "Handler: cannot find card #{message._id}"
      return
    card.get('group').get('cards').remove card, { rebroadcast: true }

  userMessage: () =>
    @user.toJSON()

  boardMessage: () =>
    message = _(@board.toJSON()).pick('_id', 'name')
    message.author = @board.currentUserId()
    message

  groupMessage: (group) =>
    attrs = _(group.changed).keys()
    message = group.toJSON()
    message = _(message).pick(attrs) if message._id                   # restrict to changed attrs on updates only
    ( message[attr] = null unless message[attr]? ) for attr in attrs  # add in any deleted attrs
    message = _(message).omit('board', 'cards', '_id', 'created', 'updated')
    return null if _(message).isEmpty()

    message._id = group.id if group.id?
    message.cid = group.cid
    message.boardId = @board.id
    message.author = @board.currentUserId()
    message

  cardMessage: (card) =>
    attrs = _(card.changed).keys()
    message = card.toJSON()
    message = _(message).pick(attrs) if message._id                   # restrict to changed attrs on updates only
    ( message[attr] = null unless message[attr]? ) for attr in attrs  # add in any deleted attrs
    message = _(message).omit('group', 'board', '_id', 'created', 'updated')
    return null if _(message).isEmpty()

    message._id = card.id if card.id?
    message.cid = card.cid
    message.boardId = @board.id
    message.author = @board.currentUserId()
    message

  deleteMessage: (model) =>
    message =
      _id: model.id
      boardId: @board.id
      author: @board.currentUserId()
    message
