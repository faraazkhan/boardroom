$ ()->
  $('[data-left-title]').each (idx, element) -> # copy 'left-title' to 'title' attribute
    $e = $(element)
    $e.attr 'title', ($e.attr 'data-left-title')
    $e.tooltip
      position: "bottom left"
      effect: "fade"
      opacity: 0.9  
