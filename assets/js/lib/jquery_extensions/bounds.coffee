$.fn.bounds = ->
  boundify = (box) ->
    box.middle = ->
      x: @left + ( @right  - @left ) / 2.0
      y: @top  + ( @bottom - @top  ) / 2.0
    box.contains = (point) ->
      @left <= point.x <= @right and @top <= point.y <= @bottom
    box.upperHalf = ->
      boundify { @left, @right, @top, bottom: @middle().y }
    box.lowerHalf = ->
      boundify { @left, @right, top: @middle().y, @bottom }
    box.extendUp = (pixels) ->
      boundify { @left, @right, top: @top - pixels, @bottom }
    box.extendDown = (pixels) ->
      boundify { @left, @right, @top, bottom: @bottom + pixels }
    box

  bounds = $(@).offset()
  bounds.bottom = bounds.top + $(@).height()
  bounds.right  = bounds.left + $(@).width()
  boundify bounds
