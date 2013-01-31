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
      groups: [new boardroom.models.Group]
      users: {}
      user_id: 1
    @boardView = new boardroom.views.Board
      model: @board
      socket: @socket

  describe 'socket events', ->
    describe 'join', ->
      beforeEach ->
        @user = { user_id: 1 }
        @socket.emit 'join', @user

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

    describe 'group.create', ->
      beforeEach ->
        @cardCount = @boardView.$('.card').length
        @groupCount = @boardView.$('.group').length
        g = 
          cards: [{}, {}, {}]  # group has 3 cards
        @socket.emit 'group.create', g

      it 'displays the new group', ->
        expect(@boardView.$('.group').length).toEqual @groupCount + 1

      it 'displays the new cards in the group', ->
        expect(@boardView.$('.card').length).toEqual @cardCount + 3

    xdescribe 'card.delete', ->
      beforeEach ->
        @card = { _id: 1 }
        @cardCount = @boardView.$('.card').length
        @socket.emit 'card.create', @card
        @socket.emit 'card.delete', @card._id

      it 'removes the card', ->
        expect(@boardView.$('.card').length).toEqual @cardCount

    describe 'update events', ->
      beforeEach ->
        @card = { _id: 1}
        @group = {_id: 2, cards: [@card]}
        @socket.emit 'group.create', @group

      describe 'card.update (text)', ->
        beforeEach ->
          @text = 'updated text'
          @socket.emit 'card.update', { _id: @card._id, text: @text }

        it 'updates the card text', ->
          cardView = @boardView.findView 1
          expect(cardView.$('textarea')).toHaveValue(@text)

      describe 'card.update (color)', ->
        beforeEach ->
          @socket.emit 'card.update', { _id: @card._id, colorIndex: 0 }

        it 'updates the card color', ->
          cardView = @boardView.findView 1
          expect(cardView.$el).toHaveClass "color-0"

    describe 'move events', ->
      beforeEach ->
        @card1 = { _id: 1}
        @group2 = {_id: 2, x: 100, y: 200, cards: [@card1]}
        @socket.emit 'group.create', @group2

        @card11 = { _id: 11 }
        @group12 = {_id: 12, x: 400, y: 400, cards: [@card11]}
        @socket.emit 'group.create', @group12
        groupView = @boardView.findView(@group12._id)

      describe 'groups.update (move)', ->
        beforeEach ->
          move = { _id: @group12._id, x: 300, y: 300, user: 'user-1' }
          @socket.emit 'group.update', move

        it 'moves the group', ->
          groupView = @boardView.findView(@group12._id)
          expect(groupView.$el.position().left).toEqual 300


        it 'locks the card to prevent other users from moving it', ->
          groupView = @boardView.findView 12
          expect(groupView.authorLock.lock_data).not.toBeUndefined()

  describe 'when double clicking the board', ->
    beforeEach ->
      @spy = sinon.spy()
      @socket.on 'group.create', @spy
      @dblclick = new $.Event 'dblclick'
      @dblclick.pageX = 200
      @dblclick.pageY = 201

    describe 'for the first card', ->
      beforeEach ->
        @boardView.cardViews = []
        @boardView.$el.trigger @dblclick

      it 'emits a "group.create" socket event', ->
        expect(@spy.called).toBeTruthy()

      it 'creates the group at the mouse location', ->
        call = @spy.firstCall
        expect(call.args[0].x).toEqual 200 - 10
        expect(call.args[0].y).toEqual 201 - 10

    describe 'for the second card and beyond', ->
      beforeEach ->
        @boardView.$el.trigger @dblclick

      it 'emits a "group.create" socket event', ->
        expect(@spy.called).toBeTruthy()

      it 'creates the group at the mouse location', ->
        call = @spy.firstCall
        expect(call.args[0].x).toEqual 200 - 10
        expect(call.args[0].y).toEqual 201 - 10

  describe 'when clicking the add card button of a group', ->
    beforeEach ->
      @spy = sinon.spy()
      @cards = [{_id: 1}, { _id: 2}]
      @group = {_id: 2, x: 100, y: 200, cards: @cards}
      @socket.emit 'group.create', @group
      @socket.on 'group.card.create', @spy

    it 'creates a new card in the group', ->
      groupView = @boardView.findView(@group._id)
      @click = new $.Event 'click'
      groupView.$('.add-card').trigger @click
      expect(@spy.called).toBeTruthy()
