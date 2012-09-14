describe 'boardroom.views.Card', ->
  describe 'socket events', ->
    beforeEach ->
      @socket = new io.Socket

    describe 'color', ->
      beforeEach ->
        @card = new boardroom.models.Card
          id: 1
        @cardView = new boardroom.views.Card
          model: @card
          socket: @socket
        @cardView.render()

        @color =
          _id: @card.id
          colorIndex: 0
        @socket.emit 'color', @color

      it 'updates the card color', ->
        expect(@cardView.$el).toHaveClass "color-#{@color.colorIndex}"

    describe 'delete', ->
      beforeEach ->
        setFixtures '''
          <div class="board"></div>
        '''
        @card = new boardroom.models.Card
          id: 1
        @cardView = new boardroom.views.Card
          model: @card
          socket: @socket
        $('.board').append @cardView.render().el

        data =
          _id: @card.id
        @socket.emit 'delete', data

      it 'removes itself', ->
        expect($('.board')).not.toContain('.card')

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
        @socket = new io.Socket
        @card = new boardroom.models.Card
          id: 1
        @cardView = new boardroom.views.Card
          model: @card
          socket: @socket
        @cardView.render()
        @color = sinon.spy()
        @socket.on 'color', @color

        @colorIndex = '3'
        @cardView
          .$(".color-#{@colorIndex}")
          .click()

      it 'changes its color', ->
        expect(@cardView.$el).toHaveClass "color-#{@colorIndex}"

      it 'emits a "color" socket event', ->
        expect(@color.called).toBeTruthy()
        [args] = @color.lastCall.args
        expect(args._id).toEqual @card.id
        expect(args.colorIndex).toEqual @colorIndex

    describe 'entering text', ->
      beforeEach ->
        @socket = new io.Socket
        @board = new boardroom.models.Board
          user_id: 1
        @card = new boardroom.models.Card
          id: 2
          board: @board
          authors: []
        @cardView = new boardroom.views.Card
          model: @card
          socket: @socket
        @cardView.render()
        @text = sinon.spy()
        @socket.on 'text', @text
        @authorCount = @card.get('authors').length

        event = $.Event 'keyup'
        @cardView
          .$('textarea')
          .trigger(event)

      it 'adds the author to its author list', ->
        expect(@cardView.$('.authors img').length).toEqual @authorCount + 1

      it 'emits a "text" socket event', ->
        expect(@text.called).toBeTruthy()
        [args] = @text.lastCall.args
        expect(args._id).toEqual @card.id
        expect(args.text).toEqual ''
        expect(args.author).toEqual @board.get('user_id')

    describe 'finish entering text', ->
      beforeEach ->
        @socket = new io.Socket
        @board = new boardroom.models.Board
          id: 1
          name: 'name-1'
          user_id: 1
        @card = new boardroom.models.Card
          id: 2
          board: @board
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
        [args] = @textCommit.lastCall.args
        expect(args._id).toEqual @card.id
        expect(args.text).toEqual ''
        expect(args.board_name).toEqual @board.get('name')
        expect(args.author).toEqual @board.get('user_id')

    describe 'deleting the card', ->
      beforeEach ->
        @socket = new io.Socket
        @board = new boardroom.models.Board
          user_id: 1
        @card = new boardroom.models.Card
          id: 2
          board: @board
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
        [args] = @delete.lastCall.args
        expect(args._id).toEqual @card.id
        expect(args.author).toEqual @board.get('user_id')
