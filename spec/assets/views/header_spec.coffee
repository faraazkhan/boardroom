describe 'boardroom.views.Header', ->
  beforeEach ->
    setFixtures '''
      <div id="board-nav">
        <input id="name" />
        <button class="create" />
      </div>
    '''
    @socket = new io.Socket
    @header = new boardroom.views.Header
      model: new boardroom.models.Board
      socket: @socket

  describe 'socket events', ->
    describe "when the board's name changes", ->
      beforeEach ->
        @name = 'name'
        @socket.emit 'board.update', _id: 1, name: @name

      it 'updates its name', ->
        expect(@header.$('#name')).toHaveValue @name

  describe 'DOM events', ->
    describe 'when entering a name', ->
      describe 'and the user is still name', ->
        beforeEach ->
          @nameChanged = sinon.spy()
          @socket.on 'board.update', @nameChanged

          keyup = $.Event 'keyup'
          keyup.keyCode = 50
          @header
            .$('#name')
            .trigger keyup

        it 'emits the "name changed" socket event', ->
          expect(@nameChanged.called).toBeTruthy()
          [args] = @nameChanged.lastCall.args
          expect(args.name).toEqual ''

      describe 'the enter key is hit', ->
        beforeEach ->
          $('input#name').focus()
          enter = $.Event 'keyup'
          enter.keyCode = 13
          @header
            .$('#name')
            .trigger enter

        it 'blurs the input field', ->
          expect(document.activeElement.tagName).not.toMatch /input/i

