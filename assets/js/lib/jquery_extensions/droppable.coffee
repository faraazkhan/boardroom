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
    return false unless data?
    return false if settings.shouldBlockHover(data)
    threshold = settings.threshold
    offset = $this.offset()
    (offset.left - threshold) <= data.x <= (offset.left + threshold) and (offset.top - threshold) <= data.y <= (offset.top + threshold)

  $(window).on 'drag', (event, data) ->
    return if data? and $this[0] == data.target
    return unless $this.is(':visible')

    nowHovering = isHovering(data)
    if nowHovering and hovering == false
      hovering = true
      settings.onHover event, data.target

    if !nowHovering and hovering == true
      hovering = false
      settings.onBlur event, data.target

  $(window).on 'drop', (event, data) ->
    return if data? and $this[0] == data.target
    return unless $this.is(':visible')

    if isHovering(data)
      settings.onDrop data.mouseEvent, data.target

  $this
