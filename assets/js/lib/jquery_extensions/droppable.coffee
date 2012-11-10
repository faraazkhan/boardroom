$.fn.droppable = (opts) ->
  $this = this

  settings = $.extend true,
    threshold: 50
    onHover: (event, target) ->
    onBlur: (event, target) ->
    onDrop: (event, target) ->
    shouldBlockHover: (coordinates) -> false
  , opts

  hovering = false

  isHovering = (data) ->
    threshold = settings.threshold
    offset = $this.offset()
    return false if settings.shouldBlockHover(data)
    (offset.left - threshold) <= data.x <= (offset.left + threshold) and (offset.top - threshold) <= data.y <= (offset.top + threshold)

  $(window).on 'drag', (event, data) ->
    return if $this[0] == data.target

    nowHovering = isHovering(data)
    if nowHovering and hovering == false
      console.log "hovering"  # here to notice phantom group: to trigger: merge a group1 into a group0, then hover group0 to top left of board
      hovering = true
      settings.onHover event, data.target

    if !nowHovering and hovering == true
      hovering = false
      settings.onBlur event, data.target

  $(window).on 'drop', (event, data) ->
    return if $this[0] == data.target

    if isHovering(data)
      settings.onDrop data.mouseEvent, data.target

  $this
