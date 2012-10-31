$.fn.droppable = (opts) ->
  $this = this

  settings = $.extend true,
    threshold = 50
    onHover: (target) ->
    onBlur: (target) ->
  , opts

  $('body').on 'drag', (event, data) ->
    return if $this[0] == data.target

    pos = $this.position()
    hovering = (data) ->
      pos.left <= data.x <= (pos.left + threshold) and pos.top <= data.y <= (pos.top + threshold)

    if hovering(data)
      settings.onHover data.target
      #$this.addClass 'stackable' unless $this.is '.stackable'
    else
      settings.onBlur data.target
      #$this.removeClass 'stackable' if $this.is '.stackable'

  $this
