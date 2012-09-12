class boardroom.models.CardLock
  constructor: ->
    @cardLocks = {}

  poll: (expirationCallback) ->
    checkForExpiredLocks = =>
      currentTime = new Date().getTime()
      for cardId, cardLock of @cardLocks
        timeout = if cardLock.move then 500 else 5000
        lockExpired = currentTime - cardLock.updated > timeout
        if lockExpired
          expirationCallback cardId
          delete @cardLocks[cardId]

    setInterval checkForExpiredLocks, 100

  lock: (id, data) ->
    @cardLocks[id] = data
