class boardroom.utils.Metrics

  trackable:
    [ 'card.create', 'card.delete', 'join' ]

  labels:
    join: (data) -> "#{data.source}: #{data.username}"

  constructor: (@board) ->

  track: (event, data) ->
    return unless @trackable.indexOf(event) >= 0
    label = @labelFor event, data
    window.ga 'send', 'event', "board-#{@board.id}", event, label

  labelFor: (event, data) ->
    @labels[event] data if @labels[event]?
