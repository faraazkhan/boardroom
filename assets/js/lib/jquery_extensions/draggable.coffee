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

  downEvent = ( if Modernizr.touch then 'touchstart' else 'mousedown' ) + '.draggable'
  upEvent   = ( if Modernizr.touch then 'touchend'   else 'mouseup' )   + '.draggable'
  moveEvent = ( if Modernizr.touch then 'touchmove'  else 'mousemove' ) + '.draggable'

  mousedown = (e) ->
    return true if e.type == 'mousedown' && e.which != 1   # only left clicks drags
    return true if e.type == 'mousedown' && e.ctrlKey      # crtl is the same as right click on os x
    return true unless settings.isOkToDrag()
    return true unless settings.isTarget(e.target)

    @isDragging = false
    e.stopPropagation()

    # this fixes a WebKit cursor issue (although there may be a better way)
    e.originalEvent.preventDefault() unless $(e.target).is('textarea') || $(e.target).is('input')

    origX = lastX = e.originalEvent.pageX
    origY = lastY = e.originalEvent.pageY
    origLeft = $this.offset().left
    origTop = $this.offset().top

    mousemove = (e) ->
      settings.startedDragging() unless @isDragging
      @isDragging = true
      deltaX = e.originalEvent.pageX - origX
      deltaY = e.originalEvent.pageY - origY

      offsetX = origLeft + deltaX
      offsetX = Math.max [offsetX, settings.minX]...
      offsetY = origTop + deltaY
      offsetY = Math.max [offsetY, settings.minY]...
      offset = settings.position deltaX, deltaY, offsetX, offsetY, e

      $this.offset left: offset.left, top: offset.top

      lastX = e.originalEvent.pageX
      lastY = e.originalEvent.pageY

      trigger 'drag'
      settings.onMouseMove e
      false

    mouseup = (e) ->
      e.stopPropagation()
      $(window).off moveEvent
      $(window).off upEvent
      if @isDragging
        settings.onMouseUp e
        settings.stoppedDragging()
        trigger 'drop', e

      @isDragging = false
      true

    $(window).on moveEvent, mousemove
    $(window).on upEvent, mouseup

    settings.onMouseDown e
    true

  $this.on downEvent, mousedown

  $this
