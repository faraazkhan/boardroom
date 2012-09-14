$.fn.onMousePause = (callback, duration = 400) ->
  timeout = null

  @on 'mousemove.onMousePause', (event) =>
    clearTimeout timeout
    executeCallback = =>
      callback.call @, event
    timeout = setTimeout executeCallback, duration

  off: =>
    clearTimeout timeout
    @off '.onMousePause'
