$ ()->
  $('[left-title]').each (idx, element) -> # copy 'left-title' to 'title' attribute
    $e = $(element);
    $e.attr 'title', ($e.attr 'left-title')
    $e.attr 'left-title', ''

  $('[left-title]').tooltip # create jquery tooltip on the left
    position: "center left"
    offset: [-2, -10]
    effect: "fade"
    opacity: 0.6

  $('[right-title]').each (idx, element) -> # copy 'right-title' to 'title' attribute
    $e = $(element);
    $e.attr 'title', ($e.attr 'right-title')
    $e.attr 'right-title', ''

  $('[right-title]').tooltip # create jquery tooltip on the right
    position: "center right"
    offset: [-2, 10]
    effect: "fade"
    opacity: 0.6

