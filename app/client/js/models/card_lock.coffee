class boardroom.models.CardLock
  constructor: ->
    @locks = {}

  poll: (expirationCallback) ->
    checkForExpiredLocks = =>
      currentTime = new Date().getTime()
      for cardId, cardLock of @locks
        timeout = if cardLock.move then 500 else 5000
        lockExpired = currentTime - cardLock.updated > timeout
        if lockExpired
          expirationCallback cardId
          delete @locks[cardId]

    setInterval checkForExpiredLocks, 100

  lock: (id, data) ->
    @locks[id] = data
