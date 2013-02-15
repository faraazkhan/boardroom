class boardroom.models.Lock
  constructor: (@onLock, @onUnlock) ->
    @timing = undefined
    @poll()

  poll: =>
    checkForExpiredLocks = =>
      if @timing?
        currentTime = new Date().getTime()
        lockExpired = currentTime - @timing.locked > @timing.timeout
        if lockExpired
          delete @timing
          @onUnlock()

    setInterval checkForExpiredLocks, 100

  lock: (timeout, user, message) =>
    locked = new Date().getTime()
    @timing = { locked, timeout }
    @onLock user, message
