describe 'boardroom.views.Card', ->
  describe 'socket events', ->
    beforeEach ->
      @socket = new io.Socket

  describe 'DOM events', ->
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

    describe 'clicking a color', ->
      beforeEach ->
        @color = sinon.spy()
        @socket.on 'card.update', @color

        @colorIndex = '3'
        @cardView
          .$(".color-#{@colorIndex}")
          .click()

      it 'changes its color', ->
        expect(@cardView.$el).toHaveClass "color-#{@colorIndex}"

      it 'emits a "card.update" socket event', ->
        expect(@color.called).toBeTruthy()
        [args] = @color.lastCall.args
        expect(args._id).toEqual @card.id
        expect(args.colorIndex).toEqual @colorIndex

    describe 'entering text', ->
      beforeEach ->
        @text = sinon.spy()
        @socket.on 'card.update', @text
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

    describe 'deleting the card', ->
      beforeEach ->
        @delete = sinon.spy()
        @socket.on 'card.delete', @delete

        @cardView
          .$('.delete')
          .click()

      it 'emits a "delete" socket event', ->
        expect(@delete.called).toBeTruthy()
        [args] = @delete.lastCall.args
        expect(args).toEqual @card.id
