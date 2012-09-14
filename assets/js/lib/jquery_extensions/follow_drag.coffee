$.fn.followDrag = (opts) ->
  $this = this

  settings = $.extend true,
    otherFollowers : []
    onMouseMove : () ->
    onMouseUp : () ->
    position : (dx, dy, x, y) -> left: x, top: y
  , opts

  $this.on 'mousedown.followDrag', (e) ->
    origX = lastX = e.pageX
    origY = lastY = e.pageY
    origLeft = $this.offset().left
    origTop = $this.offset().top

    $(window).on 'mousemove.followDrag', (e) ->
      deltaX = e.pageX - origX
      deltaY = e.pageY - origY

      offsetX = origLeft + deltaX
      offsetY = origTop  + deltaY

      offset = settings.position deltaX, deltaY, offsetX, offsetY, e

      $this.add(settings.otherFollowers).each () ->
        $(this).offset left: offset.left, top: offset.top

      lastX = e.pageX
      lastY = e.pageY

      settings.onMouseMove()

    $(window).on 'mouseup.followDrag', (e) ->
      $(window).off 'mousemove.followDrag'
      settings.onMouseUp()
  $this
