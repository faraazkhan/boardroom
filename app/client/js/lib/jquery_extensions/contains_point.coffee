$.fn.containsPoint = (x, y) ->
  dx = x - @offset().left
  dy = y - @offset().top
  dx > 0 && dy > 0 && dx < @outerWidth() && dy < @outerHeight()
