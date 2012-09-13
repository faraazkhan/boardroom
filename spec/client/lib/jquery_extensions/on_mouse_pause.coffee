# Note: useFakeTimers seems to mess up the scheduling of asynchronous tests
# (tests that take a done argument). If you need async, try moving them to a
# separate file.
describe '$', ->
  describe '#onMousePause', ->
    mousepause = undefined
    div = undefined
    onMousePause = undefined

    beforeEach ->
      @clock = sinon.useFakeTimers()

    afterEach ->
      @clock.restore()

    describe 'by default', ->
      beforeEach ->
        setFixtures '''
          <div id="board" />
        '''
        @callback = sinon.spy()
        @$div = $ '#board'
        @onMousePause = @$div.onMousePause @callback, 10
        @event = $.Event 'mousemove'

        @$div.trigger @event

      it 'calls the callback after the specified wait', ->
        @clock.tick(5)
        expect(@callback.called).toBeFalsy()

        @clock.tick(6)
        expect(@callback.called).toBeTruthy()
        expect(@callback.calledWith(@event)).toBeTruthy()

    describe 'after registering a mouse pause callback', ->
      beforeEach ->
        setFixtures '''
          <div id="board" />
        '''
        @callback = sinon.spy()
        @$div = $ '#board'
        @onMousePause = @$div.onMousePause @callback, 10

        triggerOnMousePause = =>
          @$div.trigger 'mousemove'
        interval = setInterval triggerOnMousePause, 5
        stopTriggeringOnMousePause = ->
          clearInterval interval
        setTimeout stopTriggeringOnMousePause, 10

      it 'calls the callback after the specified wait since the last mousemove', ->
        @clock.tick 11
        expect(@callback.called).toBeFalsy()

        @clock.tick 20
        expect(@callback.called).toBeTruthy()

      describe '#off', ->
        it 'cancels any pending callback', ->
          @clock.tick 10
          @onMousePause.off()
          @clock.tick 10
          expect(@callback.called).toBeFalsy()

        it 'cancels the listener', ->
          @onMousePause.off()
          @$div.trigger 'mousemove'
          @clock.tick 11
