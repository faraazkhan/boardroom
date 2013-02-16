describe 'boardroom.models.Lock', ->
  describe '#lock', ->
    beforeEach ->
      @clock = sinon.useFakeTimers()
      onLock = => @locked = true
      onUnlock = => @locked = false
      @lock = new boardroom.models.Lock onLock, onUnlock
      @lock.lock 500

    afterEach ->
      @clock.restore()

    it 'locks the item', ->
      expect(@locked).toEqual true

    it 'eventually unlocks the item', ->
      @clock.tick 600
      expect(@locked).toEqual false
