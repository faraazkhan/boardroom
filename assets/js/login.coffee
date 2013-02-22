$ ->
  randomizeBackgroundImage()
  addFormInteractivity()

randomizeBackgroundImage = ->
  random = Math.floor(Math.random() * 5 + 1)
  prefix = "/images/bg_"
  suffix = ".jpg"

  image_url = prefix + random + suffix
  $.backstretch image_url, fade: 800

addFormInteractivity = ->
  $('input[type="text"]').focus ->
    if @value is @defaultValue
      @value = ""
    else
      s = => @select()
      setTimeout s, 10

  $("input[type='text']").blur ->
      @value = @defaultValue if @value is ""

  $('form#login button').click (event) ->
    event.preventDefault()

    $input = $('#user_id')
    val = $input.val()
    if val == '' or val == $input.attr('defaultValue')
      return false

    $input.val("@#{val}") unless val.match(/@/) or event.shiftKey
    $(@).closest('form').submit()
