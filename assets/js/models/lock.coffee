class boardroom.models.Lock
  constructor: ->
    @lock_data = undefined

  poll: (expirationCallback) ->
    checkForExpiredLocks = =>
      if @lock_data?
        currentTime = new Date().getTime()
        lockExpired = currentTime - @lock_data.locked > @lock_data.timeout
        if lockExpired
          delete @lock_data
          expirationCallback()

    setInterval checkForExpiredLocks, 100

  lock: (timeout = 2000) ->
    locked = new Date().getTime()
    @lock_data = { locked, timeout }
