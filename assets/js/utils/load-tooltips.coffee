$ ()->
  $('[data-left-title]').each (idx, element) -> # copy 'left-title' to 'title' attribute
    $e = $(element)
    $e.attr 'title', ($e.attr 'data-left-title')
    $e.tooltip
      position: "center left"
      effect: "fade"
      opacity: 0.9  

  $('[data-right-title]').each (idx, element) -> # copy 'right-title' to 'title' attribute
    $e = $(element);
    $e.attr 'title', ($e.attr 'data-right-title')
    $e.tooltip 
      position: "center right"
      effect: "fade"
      opacity: 0.9

