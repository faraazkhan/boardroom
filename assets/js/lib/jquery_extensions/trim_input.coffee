$.fn.textMetrics = () ->
  if $(@).is 'input' or $(@).is 'textarea'
    html = $(@).val()
    html = $(@).attr('placeholder') if html == ''
  else
    html = $(@).html()
  html ?= ''
  $div = $("<div></div>").
    text(html).
    css({ position: 'absolute', left: -1000, top: -1000 }).
    appendTo($('body'))
  styles = [ 'font-size', 'font-style', 'font-weight', 'font-family', 'line-height', 'text-transform', 'letter-spacing' ]
  $div.css style, $(@).css(style) for style in styles
  metrics = { height: $div.innerHeight(), width: $div.innerWidth() }
  $div.remove()
  metrics

$.fn.adjustWidth = ->
  if $(@).is(':focus')
    return
  width = $(@).textMetrics().width + 3
  width = Math.min width, $(@).data('maxWidth')
  width = Math.max width, $(@).data('minWidth')
  $(@).css 'width', width

$.fn.trimInput = (minWidth) ->
  @each ->
    originalWidth = $(@).css('width')

    maxWidth = $(@).innerWidth()

    $(@).data('maxWidth', maxWidth)
    $(@).data('minWidth', minWidth)

    $(@).adjustWidth() if not $(@).is(':focus')

    $(@).blur =>
      $(@).adjustWidth()

    $(@).focus =>
      $(@).css 'width', ''
      $(@).data('maxWidth', $(@).innerWidth())
