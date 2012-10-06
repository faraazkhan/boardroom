describe 'boardroom.views.Board', ->
  beforeEach ->
    setFixtures '''
      <div class="board">
        <div id="connection-status-modal">
          <div id="connection-status"></div>
        </div>
      </div>
    '''
    @socket = new io.Socket
    @board = new boardroom.models.Board
      cards: [new boardroom.models.Card]
      users: {}
      user_id: 1
    @boardView = new boardroom.views.Board
      model: @board
      socket: @socket

  describe 'socket events', ->
    describe 'joined', ->
      beforeEach ->
        @user =
          user_id: 1
        @socket.emit 'joined', @user

      it "adds the new user to the board's user list", ->
        users = @board.get 'users'
        expect(users[@user.user_id]).toEqual @user

    describe 'connect', ->
      beforeEach ->
        @join = sinon.spy()
        @socket.on 'join', @join
        @socket.emit 'connect', {}

      it 'publishes that a user joined', ->
        expect(@join.called).toBeTruthy()
        [args] = @join.lastCall.args
        expect(args.user_id).toEqual @board.get('user_id')

    describe 'disconnect', ->
      beforeEach ->
        @boardView = new boardroom.views.Board
          model: @board
          socket: @socket
        @socket.emit 'disconnect', {}

      it 'displays a disconnected status', ->
        expect(@boardView.$('#connection-status')).toHaveText('Disconnected')
        expect(@boardView.$('#connection-status-modal')).toBeVisible()

    describe 'reconnecting', ->
      beforeEach ->
        @boardView = new boardroom.views.Board
          model: @board
          socket: @socket
        @socket.emit 'reconnecting', {}

      it 'displays a reconnecting status', ->
        expect(@boardView.$('#connection-status')).toHaveText('Reconnecting...')

    describe 'reconnect', ->
      beforeEach ->
        @boardView = new boardroom.views.Board
          model: @board
          socket: @socket
        @socket.emit 'reconnect', {}

      it 'hides any status message', ->
        expect(@boardView.$('#connection-status')).toBeEmpty()
        expect(@boardView.$('#connection-status-modal')).toBeHidden()

    describe 'add', ->
      beforeEach ->
        @cardCount = @boardView.$('.card').length
        @socket.emit 'add', {}

      it 'displays the new card', ->
        expect(@boardView.$('.card').length).toEqual @cardCount + 1

    describe 'move', ->
      beforeEach ->
        @card =
          _id: 1
          x: 100
          y: 200
        @socket.emit 'add', @card

        move =
          _id: @card._id
          x: 200
          y: 200
          user: 'user-1'
        @socket.emit 'move', move

      it 'locks the card to prevent other users from moving it', ->
        expect(@boardView.cardLock.locks[@card._id]).not.toBeUndefined()

    describe 'text', ->
      beforeEach ->
        @card =
          _id: 1
          x: 100
          y: 200
        @socket.emit 'add', @card

        @text = 'updated text'
        @socket.emit 'text',
          _id: @card._id
          author: 'author-1'
          text: @text

      it 'updates the card text', ->
        cardView = _.last @boardView.cardViews
        expect(cardView.$('textarea')).toHaveValue(@text)

  describe 'when double clicking the board', ->
    beforeEach ->
      @add = sinon.spy()
      @socket.on 'add', @add
      dblclick = new $.Event 'dblclick'
      dblclick.pageX = 200
      dblclick.pageY = 201
      @boardView.$el.trigger dblclick

    it 'emits an "add" socket event', ->
      expect(@add.called).toBeTruthy()

    it 'creates the card at the mouse location', ->
      call = @add.firstCall
      # our test $("<div id='board'>") elements always have an offset of
      # top: 5, left: 5
      # for some reason - mike
      expect(call.args[0].x).toEqual 200 - 10 - 5
      expect(call.args[0].y).toEqual 201 - 10 - 5
