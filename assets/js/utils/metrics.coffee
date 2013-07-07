class boardroom.utils.Metrics

  trackable:
    [ 'card.create', 'card.delete', 'join' ]

  constructor: (@board) ->

  track: (event) ->
    return unless @trackable.indexOf(event) >= 0
    window.ga 'send', 'event', "board-#{@board.id}", event
