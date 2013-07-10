$.fn.removeClassMatching = (regexp) ->
  @each ->
    $(@).attr 'class', (_, value) ->
      $.trim(value.replace(regexp, ''))
