$.fn.containsPoint = (x, y) ->
  dx = x - @offset().left
  dy = y - @offset().top
  dx > 0 and dy > 0 and dx < @outerWidth() and dy < @outerHeight()
