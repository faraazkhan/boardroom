describe 'boardroom.models.CardLock', ->
  describe '#lock', ->
    beforeEach ->
      @cardLock = new boardroom.models.CardLock

      @id = 'id'
      @data = 'data'
      @cardLock.lock @id, @data

    it 'locks the item', ->
      expect(@cardLock.locks[@id]).toEqual @data

  describe '#poll', ->
    beforeEach ->
      @clock = sinon.useFakeTimers()

    afterEach ->
      @clock.restore()

    describe 'when a card move lock expires', ->
      beforeEach ->
        @id = 'id'
        @data =
          move: true
          updated: new Date().getTime()
        @cardLock = new boardroom.models.CardLock
        @cardLock.lock @id, @data

        @expirationCallback = sinon.spy()
        @cardLock.poll @expirationCallback

        @clock.tick(600)

      it 'unlocks the lock', ->
        expect(@cardLock.locks[@id]).toBeUndefined()

      it 'calls the given expiration callback', ->
        expect(@expirationCallback.called).toBeTruthy()

    describe 'when a card edit lock expires', ->
      beforeEach ->
        @id = 'id'
        @data =
          updated: new Date().getTime()
        @cardLock = new boardroom.models.CardLock
        @cardLock.lock @id, @data

        @expirationCallback = sinon.spy()
        @cardLock.poll @expirationCallback

        @clock.tick(6000)

      it 'unlocks the lock', ->
        expect(@cardLock.locks[@id]).toBeUndefined()
