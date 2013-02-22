$.fn.placeholder = (submitButton, options) ->
  options = _.extend
    decorator: ->
  , options

  $input = $(@)
  shiftKeyPressed = false

  $input.focus ->
    if @value is @defaultValue
      @value = ""
    else
      s = => @select()
      setTimeout s, 10

  $input.blur ->
    @value = @defaultValue if @value is ""

  $input.keydown (event) ->
    shiftKeyPressed = true if event.keyCode == 16

  $input.keyup (event) ->
    shiftKeyPressed = false if event.keyCode == 16

  $(submitButton).click (event) ->
    event.preventDefault()

    val = $input.val()
    if val == '' or val == $input.attr('defaultValue')
      return false

    options.decorator $input, (event.shiftKey or shiftKeyPressed)
    $(@).closest('form').submit()
