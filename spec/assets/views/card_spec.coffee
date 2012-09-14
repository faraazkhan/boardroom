describe 'boardroom.views.Card', ->
  describe 'socket events', ->
    beforeEach ->
      @socket = new io.Socket

    describe 'color', ->
      beforeEach ->
        @updateColor = sinon.spy boardroom.views.Card.prototype, 'updateColor'
        @card = new boardroom.models.Card
        @cardView = new boardroom.views.Card
          model: @card
          socket: @socket

        @socket.emit 'color', {}

      afterEach ->
        boardroom.views.Card.prototype.updateColor.restore()

      it 'updates the card color', ->
        expect(@updateColor.called).toBeTruthy()

    describe 'delete', ->
      beforeEach ->
        @removeIfDeleted = sinon.spy boardroom.views.Card.prototype, 'removeIfDeleted'
        @card = new boardroom.models.Card
        @cardView = new boardroom.views.Card
          model: @card
          socket: @socket

        @socket.emit 'delete', {}

      afterEach ->
        boardroom.views.Card.prototype.removeIfDeleted.restore()

      it 'removes itself', ->
        expect(@removeIfDeleted.called).toBeTruthy()

  describe 'DOM events', ->
    describe 'moving the card', ->
      beforeEach ->
        @card = new boardroom.models.Card
        @socket = new io.Socket
        @cardView = new boardroom.views.Card
          model: @card
          socket: @socket
        @onMouseDown = sinon.spy @cardView.card, 'onMouseDown'
        @cardView.render()

        @cardView
          .$el
          .mousedown()

      it 'updates its position', ->
        expect(@onMouseDown.called).toBeTruthy()

    describe 'clicking a color', ->
      beforeEach ->
        @card = new boardroom.models.Card
        @socket = new io.Socket
        @cardView = new boardroom.views.Card
          model: @card
          socket: @socket
        @cardView.render()
        @color = sinon.spy()
        @socket.on 'color', @color

        @cardView
          .$('.color')
          .click()

      it 'emits a "color" socket event', ->
        expect(@color.called).toBeTruthy()

    describe 'entering text', ->
      beforeEach ->
        @card = new boardroom.models.Card
          board: new boardroom.models.Board
        @socket = new io.Socket
        @cardView = new boardroom.views.Card
          model: @card
          socket: @socket
        @cardView.render()
        @text = sinon.spy()
        @socket.on 'text', @text

        @cardView
          .$('textarea')
          .keyup()

      it 'emits a "text" socket event', ->
        expect(@text.called).toBeTruthy()

    describe 'finish entering text', ->
      beforeEach ->
        @card = new boardroom.models.Card
          board: new boardroom.models.Board
        @socket = new io.Socket
        @cardView = new boardroom.views.Card
          model: @card
          socket: @socket
        @cardView.render()
        @textCommit = sinon.spy()
        @socket.on 'text_commit', @textCommit

        @cardView
          .$('textarea')
          .change()

      it 'emits a "text commit" socket event', ->
        expect(@textCommit.called).toBeTruthy()

    describe 'deleting the card', ->
      beforeEach ->
        @card = new boardroom.models.Card
          board: new boardroom.models.Board
        @socket = new io.Socket
        @cardView = new boardroom.views.Card
          model: @card
          socket: @socket
        @cardView.render()
        @delete = sinon.spy()
        @socket.on 'delete', @delete

        @cardView
          .$('.delete')
          .click()

      it 'emits a "delete" socket event', ->
        expect(@delete.called).toBeTruthy()
