describe 'boardroom.views.Board', ->
  beforeEach ->
    setFixtures '''
      <div class="board">
      </div>
    '''
    @board = new boardroom.models.Board
      cards: [new boardroom.models.Card]
      users: {}
    @socket = new io.Socket

  describe 'socket events', ->
    describe 'joined', ->
      beforeEach ->
        @addUser = sinon.spy @board, 'addUser'
        @boardView = new boardroom.views.Board
          model: @board
          socket: @socket

        @socket.emit 'joined', {}

      it 'adds the new user to the user list', ->
        expect(@addUser.called).toBeTruthy()

    describe 'connect', ->
      beforeEach ->
        @publishUserJoinedEvent = sinon.spy boardroom.views.Board.prototype, 'publishUserJoinedEvent'
        @boardView = new boardroom.views.Board
          model: @board
          socket: @socket

        @socket.emit 'connect', {}

      afterEach ->
        boardroom.views.Board.prototype.publishUserJoinedEvent.restore()

      it 'publishes that a user joined', ->
        expect(@publishUserJoinedEvent.called).toBeTruthy()

    describe 'boardDeleted', ->
      beforeEach ->
        @redirectToBoardsList = sinon.stub boardroom.views.Board.prototype, 'redirectToBoardsList'
        @boardView = new boardroom.views.Board
          model: @board
          socket: @socket

        @socket.emit 'boardDeleted', {}

      afterEach ->
        boardroom.views.Board.prototype.redirectToBoardsList.restore()

      it 'redirects to the user to the board list', ->
        expect(@redirectToBoardsList.called).toBeTruthy()

    describe 'add', ->
      beforeEach ->
        @displayNewCard = sinon.spy boardroom.views.Board.prototype, 'displayNewCard'
        @boardView = new boardroom.views.Board
          model: @board
          socket: @socket

        @socket.emit 'add', {}

      afterEach ->
        boardroom.views.Board.prototype.displayNewCard.restore()

      it 'displays the new card', ->
        expect(@displayNewCard.called).toBeTruthy()

    describe 'move', ->
      beforeEach ->
        @updateCardPosition = sinon.spy boardroom.views.Board.prototype, 'updateCardPosition'
        @boardView = new boardroom.views.Board
          model: @board
          socket: @socket

        @socket.emit 'move', {}

      afterEach ->
        boardroom.views.Board.prototype.updateCardPosition.restore()

      it 'moves the card to the new position', ->
        expect(@updateCardPosition.called).toBeTruthy()

    describe 'text', ->
      beforeEach ->
        @updateCardText = sinon.spy boardroom.views.Board.prototype, 'updateCardText'
        @boardView = new boardroom.views.Board
          model: @board
          socket: @socket

        @socket.emit 'text', {}

      afterEach ->
        boardroom.views.Board.prototype.updateCardText.restore()

      it 'updates the card text', ->
        expect(@updateCardText.called).toBeTruthy()
