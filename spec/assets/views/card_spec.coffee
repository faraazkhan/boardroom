describe 'boardroom.views.Card', ->
  describe 'socket events', ->
    beforeEach ->
      @socket = new io.Socket

  describe 'DOM events', ->
    beforeEach ->
      @socket = new io.Socket
      @board = new boardroom.models.Board
        user_id: 1
      boardView = new boardroom.views.Board
        model: @board
        socket: @socket
      group = new boardroom.models.Group
      groupView = new boardroom.views.Group
        model: group
        socket: @socket
        boardView: boardView
      @card = new boardroom.models.Card
        id: 2
        board: @board
        authors: []
      @cardView = new boardroom.views.Card
        model: @card
        socket: @socket
        groupView: groupView
        boardView: boardView
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

    describe 'clicking +1', ->
      beforeEach ->
        @plus1 = sinon.spy()
        @socket.on 'card.update', @plus1

        @cardView
          .$(".plus1 .btn")
          .click()

      it 'increments its plus count', ->
        expect(@cardView.$('.plus1 .plus-count').text()).toBe('+1')

      it 'emits a "card.update" socket event', ->
        expect(@plus1.called).toBeTruthy()
        [args] = @plus1.lastCall.args
        expect(args._id).toEqual @card.id
        expect(args.plusAuthor).toEqual @board.get('user_id')

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

    describe 'focusing text', ->
      beforeEach ->
        @z = sinon.spy()
        @socket.on 'card.update', @z

        event = $.Event 'click'
        @cardView
          .$('textarea')
          .trigger(event)

      it 'emits a "focus" socket event', ->
        expect(@z.called).toBeTruthy()

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
