$ ->
  shiftKeyPressed = false

  randomizeBackgroundImage = ->
    random = Math.floor(Math.random() * 5 + 1)
    prefix = "/images/bg_"
    suffix = ".jpg"

    image_url = prefix + random + suffix
    $.backstretch image_url, fade: 800

  addFormInteractivity = ->
    $input = $('#user_id')

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

    $('form#login button').click (event) ->
      event.preventDefault()

      val = $input.val()
      if val == '' or val == $input.attr('defaultValue')
        return false

      $input.val("@#{val}") unless val.match(/@/) or event.shiftKey or shiftKeyPressed
      $(@).closest('form').submit()

  randomizeBackgroundImage()
  addFormInteractivity()

