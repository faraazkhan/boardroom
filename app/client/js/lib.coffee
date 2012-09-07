(($) ->

  $.fn.removeClassMatching = (regexp) ->
    this.each () ->
      remove = $(this).attr('class').match regexp
      if remove then $(this).removeClass remove.join(' ')


  $.fn.containsPoint = (x, y) ->
    dx = x - this.offset().left
    dy = y - this.offset().top
    return (dx > 0 && dy > 0 && dx < this.outerWidth() && dy < this.outerHeight())


  $.fn.onMousePause = (callback, duration = 400) ->
    $this = this
    timeout = null
    $this.on 'mousemove.onMousePause', (e) ->
      clearTimeout timeout
      timeout = setTimeout (() -> callback.call($this, e)), duration

    return off: () ->
      clearTimeout timeout
      $this.off '.onMousePause'


  $.fn.followDrag = (opts) ->
    $this = this

    settings = $.extend true,
      otherFollowers : []
      onMouseMove : () ->
      onMouseUp : () ->
      position : (dx, dy, x, y) -> left: x, top: y
    , opts

    $this.on 'mousedown.followDrag', (e) ->
      origX = lastX = e.pageX;
      origY = lastY = e.pageY;
      origLeft = $this.offset().left;
      origTop = $this.offset().top;

      $(window).on 'mousemove.followDrag', (e) ->
        deltaX = e.pageX - origX
        deltaY = e.pageY - origY

        offsetX = origLeft + deltaX
        offsetY = origTop  + deltaY

        offset = settings.position deltaX, deltaY, offsetX, offsetY, e

        $this.add(settings.otherFollowers).each () ->
          $(this).offset left: offset.left, top: offset.top

        lastX = e.pageX;
        lastY = e.pageY;

        settings.onMouseMove();

      $(window).on 'mouseup.followDrag', (e) ->
        $(window).off 'mousemove.followDrag'
        settings.onMouseUp()
    return $this


)(jQuery)