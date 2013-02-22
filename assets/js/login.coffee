#= require './vendor/jquery-1.8.1.js'
#= require './vendor/jquery.backstretch.min.js'
#= require './vendor/underscore.js'
#= require_tree './lib'

$ ->
  randomizeBackgroundImage = ->
    random = Math.floor(Math.random() * 5 + 1)
    prefix = "/images/bg_"
    suffix = ".jpg"

    image_url = prefix + random + suffix
    $.backstretch image_url, fade: 800

  addFormInteractivity = ->
    $input = $('#user_id')
    $submit = $input.closest 'form'
    decorator = ($input, shiftKey) ->
      val = $input.val()
      $input.val("@#{val}") unless val.match(/@/) or shiftKey

    $input.placeholder $submit, { decorator }

  randomizeBackgroundImage()
  addFormInteractivity()

