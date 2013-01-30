$.fn.textMetrics = () ->
  html = $(@).html() || $(@).val()
  $div = $("<div>#{html}</div>").
    css({ position: 'absolute', left: -1000, top: -1000, display: 'none' }).
    appendTo($('body'))
  styles = [ 'font-size', 'font-style', 'font-weight', 'font-family', 'line-height', 'text-transform', 'letter-spacing' ]
  $div.css style, $(@).css(style) for style in styles
  metrics = { height: $div.outerHeight(), width: $div.outerWidth() }
  $div.remove()
  metrics

$.fn.trimInput = (minWidth, maxWidth) ->
  @each ->
    maxWidth ||= $(@).css('width')

    setWidth = =>
      metrics = $(@).textMetrics()
      $(@).css 'width', $(@).textMetrics().width

    setWidth() if not $(@).is(':focus')

    $(@).blur setWidth

    $(@).focus =>
      $(@).css 'width', maxWidth
