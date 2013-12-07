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

    drop = $this.offset()
    drop.bottom = drop.top + $this.height()
    drop.right = drop.left + $this.width()

    drag = $(data.target).offset()
    drag.bottom = drag.top + $(data.target).height()
    drag.right = drag.left + $(data.target).width()

    dragPoint = [ drag.left + (drag.right  - drag.left) / 2.0,
                  drag.top  + (drag.bottom - drag.top)  / 2.0  ]

    dropBox = drop
    dropBox.contains = (point) ->
      this.left <= point[0] <= this.right and this.top <= point[1] <= this.bottom

    dropBox.contains dragPoint

  $(window).on 'drag', (event, data) ->
    return unless data?
    return if $this[0] == data.target
    return unless $this.is(':visible')

    nowHovering = isHovering(data)
    if nowHovering and hovering == false
      hovering = true
      settings.onHover event, data.target

    if !nowHovering and hovering == true
      hovering = false
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
