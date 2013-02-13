class boardroom.Watcher

  constructor: (@board) ->
    @cache = {}

  watch: ->
    setInterval @watchForEmptyGroups, 250

  watchForEmptyGroups: =>
    key = 'emptyGroup'
    @board.groups().each (group) =>
      if group.cards().length == 0
        n = @cache[key]
        if not n
          @cache[key] = 1
        else if n >= 1
          alert "Empty group: #{group.id}"
          @cache[key] = -1


