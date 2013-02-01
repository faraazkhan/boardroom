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

  describe 'set status', ->
    it 'shows the status', ->
      @board.set 'status', 'foo'
      expect(@boardView.statusModalDiv()).toBeVisible()
      expect(@boardView.statusDiv().html()).toEqual 'foo'

  describe 'clear status', ->
    it 'hides the status', ->
      @board.set 'status', 'foo'
      @board.set 'status', null
      expect(@boardView.statusModalDiv()).toBeHidden()
      expect(@boardView.statusDiv().html()).toEqual ''

  describe 'double click', ->
    beforeEach ->
      dblclick = new $.Event 'dblclick'
      dblclick.pageX = 200
      dblclick.pageY = 201
      @boardView.$el.trigger dblclick
      @pendingGroups = @board.get 'pendingGroups'

    it 'creates a new pending group', ->
      expect(@pendingGroups).toBeDefined()
      expect(@pendingGroups.length).toEqual(1)
      group = @pendingGroups.at(0)
      expect(group.get('cards').length).toEqual(0)
      expect(group.get('x')).toEqual(190)
      expect(group.get('y')).toEqual(191)


  describe 'socket events', ->
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
