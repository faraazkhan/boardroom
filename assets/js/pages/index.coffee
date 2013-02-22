#= require './vendor/jquery-1.8.1.js'
#= require './vendor/underscore.js'

$ ->
  placeholder = ->
    $input = $('#user_id')
    $submit = $input.closest 'form'
    decorator = ($input, shiftKey) ->
      val = $input.val()
      $input.val("@#{val}") unless val.match(/@/) or shiftKey

    $input.placeholder $submit, { decorator }

  placeholder()

