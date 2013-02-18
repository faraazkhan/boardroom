class boardroom.models.Lock
  constructor: (@onLock, @onUnlock) ->
    @logger = boardroom.utils.Logger.instance
    @data = undefined
    @poll()

  poll: =>
    checkForExpiredLocks = =>
      if @data?
        currentTime = new Date().getTime()
        lockExpired = currentTime - @data.locked > @data.timeout
        if lockExpired
          @onUnlock @data.args...
          delete @data

    setInterval checkForExpiredLocks, 100

  lock: (timeout, args...) =>
    locked = new Date().getTime()
    @data = { locked, timeout , args }
    @onLock args...
