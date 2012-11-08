$.fn.draggable = (opts) ->
  $this = this

  settings = $.extend true,
    onMouseMove : () ->
    onMouseUp : () ->
    onMouseDown : () ->
    isTarget : (target) -> true
    position : (dx, dy, x, y) -> left: x, top: y
  , opts

  trigger = (name) ->
    offset = $this.offset()
    $(window).trigger name,
      target: $this[0]
      x: offset.left
      y: offset.top

  $this.on 'mousedown.draggable', (e) ->
    return true unless settings.isTarget(e.target)
    e.stopPropagation()
    view = $this.data 'view'
    view.restingOffset = $this.offset() if view?

    origX = lastX = e.pageX
    origY = lastY = e.pageY
    origLeft = $this.offset().left
    origTop = $this.offset().top

    $(window).on 'mousemove.draggable', (e) ->
      deltaX = e.pageX - origX
      deltaY = e.pageY - origY

      offsetX = origLeft + deltaX
      offsetY = origTop  + deltaY

      offset = settings.position deltaX, deltaY, offsetX, offsetY, e

      $this.offset left: offset.left, top: offset.top

      lastX = e.pageX
      lastY = e.pageY

      trigger 'drag'
      settings.onMouseMove e
      false

    $(window).on 'mouseup.draggable', (e) ->
      $(window).off 'mousemove.draggable'
      $(window).off 'mouseup.draggable'
      trigger 'drop'
      settings.onMouseUp e
      false

    settings.onMouseDown e
    true

  $this
