$.fn.droppable = (opts) ->
  $this = this

  settings = $.extend true,
    priority: 0
    onHover: (event, target) ->
    onBlur: (event, target) ->
    onDrop: (event, target) ->
  , opts

  hovering = false

  isHovering = (data) ->
    return false unless data?

    drop = $this.bounds()
    drag = $(data.target).bounds()
    drop.contains drag.middle()

  $(window).on 'drag', (event, data) ->
    return unless data?
    return if $this[0] == data.target
    return unless $this.is(':visible')

    if isHovering(data)
      settings.onHover event, data.target
    else
      settings.onBlur event, data.target

  $(window).on 'drop', (event, data) ->
    return unless data?
    return if $this[0] == data.target
    return unless $this.is(':visible')

    if isHovering(data)
      drop = ->
        if event.isPropagationStopped()
          settings.onBlur event, data.target
        else
          event.stopPropagation()
          settings.onDrop data.mouseEvent, data.target

      setTimeout drop, settings.priority * 10

  $this
