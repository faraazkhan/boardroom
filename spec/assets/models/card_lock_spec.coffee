describe 'boardroom.models.CardLock', ->
  describe '#lock', ->
    beforeEach ->
      @cardLock = new boardroom.models.CardLock
      @cardLock.lock()

    it 'locks the item', ->
      expect(@cardLock.lock_data).not.toBeUndefined()

  describe '#poll', ->
    beforeEach ->
      @clock = sinon.useFakeTimers()

    afterEach ->
      @clock.restore()

    describe 'when a card lock expires', ->
      beforeEach ->
        @cardLock = new boardroom.models.CardLock
        @cardLock.lock 500

        @expirationCallback = sinon.spy()
        @cardLock.poll @expirationCallback

        @clock.tick(600)

      it 'unlocks the lock', ->
        expect(@cardLock.lock_data).toBeUndefined()

      it 'calls the given expiration callback', ->
        expect(@expirationCallback.called).toBeTruthy()
