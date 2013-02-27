class boardroom.utils.Watcher

  constructor: (@user, @board, @socket) ->
    @logger = boardroom.utils.Logger.instance
    @interval = 100
    @cache = {}

  watch: ->
    setInterval @watchForEmptyGroups, @interval
    setInterval @watchForMisplacedCards, @interval

  watchForEmptyGroups: =>
    @board.groups().each (group) =>
      if group.cards().length == 0
        @log "empty-group-#{group.id}", 2000, "empty group: #{group.id}"

  watchForMisplacedCards: =>
    @board.groups().each (group) =>
      group.cards().each (card) =>
        if card.get('x')? or card.get('y')?
          @log "misplaced-card-#{card.id}", 5000, "misplaced card: #{card.id}"

  log: (key, delay, msg) =>
    return if @cache[key] < 0
    @cache[key] ?= 0
    if @cache[key] >= delay
      @logger.error msg
      @cache[key] = -1
    else
      @socket.emit 'marker', { user: @user.get('user_id'), boardId: @board.id } if @cache[key] == 0
      @cache[key] += @interval
