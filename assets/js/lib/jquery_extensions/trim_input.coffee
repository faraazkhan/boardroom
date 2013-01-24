$.fn.trimInput = (minimumWidth, maxWidth) ->
  @each ->
    maxWidth ||= $(@).css('width')

    setWidth = =>
      zoomRatio = document.width / $(document).width()
      return if zoomRatio * @scrollWidth > @offsetWidth
      $(@).css 'width', 0
      minimumInputWidth = Math.max(zoomRatio * @scrollWidth, minimumWidth || 20)
      @style.width = minimumInputWidth + 'px'

    setWidth() if not $(@).is(':focus')

    $(@).blur setWidth

    $(@).focus =>
      $(@).css 'width', maxWidth
