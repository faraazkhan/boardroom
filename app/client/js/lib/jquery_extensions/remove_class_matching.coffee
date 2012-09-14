$.fn.removeClassMatching = (regexp) ->
  @each ->
    $(@).attr 'class', (_, value) ->
      value.replace regexp, ''
