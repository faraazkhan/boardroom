$.fn.trimInput = ->
  @each ->
    $(@).data 'original-width', $(@).css('width')

    setWidth = =>
      return if @scrollWidth > @offsetWidth
      $(@).css('width', 0)
      minimumInputWidth = Math.max(@scrollWidth, 20)
      $(@).css('width', minimumInputWidth + 'px')

    setWidth() if not $(@).is(':focus')

    $(@).blur setWidth

    $(@).focus =>
      $(@).css 'width', $(@).data('original-width')
