$.fn.draggable = (opts) ->
  $this = this

  settings = $.extend true,
    onMouseMove : () ->
    onMouseUp : () ->
    onMouseDown : () ->
    isTarget : (target) -> true
    position : (dx, dy, x, y) -> left: x, top: y
  , opts

  $this.on 'mousedown.draggable', (e) ->
    return true unless settings.isTarget(e.target)

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

      pos = $this.position()
      $('body').trigger 'drag', target: $this[0], x: pos.left, y: pos.top

      settings.onMouseMove e
      false

    $(window).on 'mouseup.draggable', (e) ->
      $(window).off 'mousemove.draggable'
      settings.onMouseUp e
      false

    settings.onMouseDown e
    false

  $this
