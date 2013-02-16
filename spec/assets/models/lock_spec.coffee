describe 'boardroom.models.Lock', ->
  describe '#lock', ->
    beforeEach ->
      @clock = sinon.useFakeTimers()
      onLock = (@lockargs...) => @locked = true
      onUnlock = (@unlockargs...) => @locked = false
      @lock = new boardroom.models.Lock onLock, onUnlock
      @lock.lock 500, 'foo', 'bar', 'baz'

    afterEach ->
      @clock.restore()

    it 'locks the item', ->
      expect(@locked).toEqual true
      expect(@lockargs).toEqual ['foo', 'bar', 'baz']

    it 'eventually unlocks the item', ->
      @clock.tick 600
      expect(@locked).toEqual false
      expect(@unlockargs).toEqual ['foo', 'bar', 'baz']
