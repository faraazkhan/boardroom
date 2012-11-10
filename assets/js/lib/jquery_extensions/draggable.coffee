$.fn.draggable = (opts) ->
  $this = this
  @isDragging = false

  settings = $.extend true,
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
      $('.board').data('view').debugShowMouse(e)
      @isDragging = true
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
      $('.board').data('view').debugShowMouse(e)
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
