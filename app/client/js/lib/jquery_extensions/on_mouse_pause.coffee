$.fn.onMousePause = (callback, duration = 400) ->
  $this = @
  timeout = null
  $this.on 'mousemove.onMousePause', (e) ->
    clearTimeout timeout
    timeout = setTimeout (-> callback.call($this, e)), duration

  off: ->
    clearTimeout timeout
    $this.off '.onMousePause'
