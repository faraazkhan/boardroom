describe 'boardroom.views.Header', ->
  beforeEach ->
    setFixtures '''
      <div id="header">
        <input id="title" />
        <button class="create" />
      </div>
    '''
    @socket = new io.Socket
    @header = new boardroom.views.Header
      model: new boardroom.models.Board
      socket: @socket

  describe 'socket events', ->
    describe "when the board's title changes", ->
      beforeEach ->
        @title = 'title'
        @socket.emit 'title_changed', @title

      it 'updates its title', ->
        expect(@header.$('#title')).toHaveValue @title

  describe 'DOM events', ->
    describe 'when entering a title', ->
      describe 'and the user is still typing', ->
        beforeEach ->
          @titleChanged = sinon.spy()
          @socket.on 'title_changed', @titleChanged

          keyup = $.Event 'keyup'
          keyup.keyCode = 50
          @header
            .$('#title')
            .trigger keyup

        it 'emits the "title changed" socket event', ->
          expect(@titleChanged.called).toBeTruthy()

      describe 'the enter key is hit', ->
        beforeEach ->
          $('input#title').focus()
          enter = $.Event 'keyup'
          enter.keyCode = 13
          @header
            .$('#title')
            .trigger enter

        it 'blurs the input field', ->
          expect(document.activeElement.tagName).not.toMatch /input/i

    describe 'when clicking the "new card" button', ->
      beforeEach ->
        @add = sinon.spy()
        @socket.on 'add', @add

        @header
          .$('.create')
          .click()

      it 'emits an "add" socket event', ->
        expect(@add.called).toBeTruthy()
