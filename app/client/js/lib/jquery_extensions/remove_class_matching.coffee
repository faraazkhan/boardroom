$.fn.removeClassMatching = (regexp) ->
  @each ->
    remove = $(@).attr('class')?.match regexp
    if remove
      $(@).removeClass remove.join(' ')
