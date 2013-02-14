$.fn.draggable = (opts) ->
  $this = this
  @isDragging = false

  settings = $.extend true,
    minX: 30
    minY: 12
    onMouseMove : () ->
    onMouseUp : () ->
    onMouseDown : () ->
    startedDragging : () -> 
    stoppedDragging : () -> 
    isOkToDrag : () -> true
    isTarget : (target) -> true
    position : (dx, dy, x, y) -> left: x, top: y
  , opts

  trigger = (name, mouseEvent) ->
    offset = $this.offset()
    $(window).trigger name,
      target: $this[0]
      mouseEvent: mouseEvent
      x: offset.left
      y: offset.top

  $this.on 'mousedown.draggable', (e) ->
    return true unless e.which == 1  # only drag left-click drags
    return true if e.ctrlKey         # ctrl is the same as right click on os x
    return true unless settings.isOkToDrag()

    @isDragging = false
    e.stopPropagation()
    # this fixes a WebKit cursor issue (although there may be a better way)
    e.originalEvent.preventDefault() unless $(e.target).is('textarea') || $(e.target).is('input')
    return true unless settings.isTarget(e.target)

    origX = lastX = e.pageX
    origY = lastY = e.pageY
    origLeft = $this.offset().left
    origTop = $this.offset().top

    $(window).on 'mousemove.draggable', (e) ->
      settings.startedDragging() unless @isDragging
      @isDragging = true
      deltaX = e.pageX - origX
      deltaY = e.pageY - origY

      offsetX = origLeft + deltaX
      offsetX = Math.max [offsetX, settings.minX]...

      offsetY = origTop + deltaY
      offsetY = Math.max [offsetY, settings.minY]...

      offset = settings.position deltaX, deltaY, offsetX, offsetY, e

      $this.offset left: offset.left, top: offset.top

      lastX = e.pageX
      lastY = e.pageY

      trigger 'drag'
      settings.onMouseMove e
      false

    $(window).on 'mouseup.draggable', (e) ->
      e.stopPropagation()
      $(window).off 'mousemove.draggable'
      $(window).off 'mouseup.draggable'
      if @isDragging
        settings.onMouseUp e
        settings.stoppedDragging()
        trigger 'drop', e

      @isDragging = false
      true

    settings.onMouseDown e
    true

  $this
