$.fn.draggable = (opts) ->
  $this = this
  @isDragging = false

  settings = $.extend true,
    minX: 30
    minY: 12
    onMouseMove : () ->
    onMouseUp : () ->
    onMouseDown : () ->
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
    @isDragging = false
    e.stopPropagation()
    return true unless settings.isTarget(e.target)
    view = $this.data 'view'
    view.restingSpot = 
      left: view.$el.css('left')
      top:  view.$el.css('top')

    origX = lastX = e.pageX
    origY = lastY = e.pageY
    origLeft = $this.offset().left
    origTop = $this.offset().top

    $(window).on 'mousemove.draggable', (e) ->
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
        trigger 'drop', e
      @isDragging = false
      true

    settings.onMouseDown e
    true

  $this
