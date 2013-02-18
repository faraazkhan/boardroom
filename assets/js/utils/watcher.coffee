class boardroom.utils.Watcher

  constructor: (@board) ->
    @logger = boardroom.utils.Logger.instance
    @cache = {}

  watch: ->
    setInterval @watchForEmptyGroups, 2000

  watchForEmptyGroups: =>
    key = 'emptyGroup'
    @board.groups().each (group) =>
      if group.cards().length == 0
        n = @cache[key]
        if not n
          @cache[key] = 1
        else if n >= 1
          @logger.warn "empty group: #{group.id}"
          @cache[key] = -1


