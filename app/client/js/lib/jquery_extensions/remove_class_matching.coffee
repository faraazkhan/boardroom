$.fn.removeClassMatching = (regexp) ->
  @each ->
    $(@).removeClass (_, klass) ->
      klass.match(regexp)?.join ' '
