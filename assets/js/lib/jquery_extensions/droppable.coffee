$.fn.droppable = (opts) ->
  $this = this

  settings = $.extend true,
    threshold = 88
    onHover: (target) ->
    onBlur: (target) ->
    onDrop: (target) ->
  , opts

  hovering = false

  isHovering = (data) ->
    pos = $this.position()
    (pos.left - threshold) <= data.x <= (pos.left + threshold) and (pos.top - threshold) <= data.y <= (pos.top + threshold)

  $(window).on 'drag', (event, data) ->
    return if $this[0] == data.target

    if isHovering(data) and hovering == false
      console.log "hovering"  # here to notice phantom group: to trigger: merge a group1 into a group0, then hover group0 to top left of board
      hovering = true
      settings.onHover data.target

    if ! isHovering(data) and hovering == true
      hovering = false
      settings.onBlur data.target

  $(window).on 'drop', (event, data) ->
    return if $this[0] == data.target

    if isHovering(data)
      settings.onDrop data.target

  $this
