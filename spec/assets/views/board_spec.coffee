describe 'boardroom.views.Board', =>
  beforeEach =>
    setFixtures '''
      <html><body style="width:3000; height:3000">
      <div class="board">
        <div id="connection-status-modal">
          <div id="connection-status"></div>
        </div>
      </div>
      </body></html>
    '''
    card1Data = { _id: 'c1', text: 'fum', authors: ['@card_cat'], colorIndex: 2, x: 220, y: 225}
    card2Data = { _id: 'c2', text: 'foo', authors: ['@card_maker'], colorIndex: 1, x: 20, y: 25}
    groups = [ { _id: 'g1', cards:[ card1Data ] }, { _id: 'g2', cards: [ card2Data ] } ]
    boardData = { _id: 'b1',  name:'test-board', status:'start', user_id: '@carbon_five', groups }

    # initialize the board
    @board = new boardroom.models.Board boardData
    @boardView = new boardroom.views.Board
      model: @board

    # Grab a reference to the card model and View for testing
    @group1View = @boardView.groupViews[0]
    @card1View = @groupView.cardViews[0]
    @group1 = @group1View.model
    @card1 = @card1View.model

    @group2View = @boardView.groupViews[1]
    @card2View = @group2View.cardViews[0]
    @group2 = @group2View.model
    @card2 = @card2View.model

  ###
  # Render Events
  # Test Pattern For A Render Event :
  # 1. grab the (existing) oldValue  from the model
  # 2. verify that elements for the oldValue have been rendered
  # 3. prepare a newValue
  # 4. set the newValue on the model
  # 5. verify that any elements for the new value have been rendered
  ###
  describe 'render event', =>

    it 'displays', =>
      expect($('.board').length).toBeGreaterThan 0
      expect($('.group').length).toEqual 2
      expect($('.card').length).toEqual 2

    describe 'when a status is set', =>
      beforeEach =>
        modelProperty = 'status'

        oldValue = @board.get(modelProperty)
        expect(@boardView.$('#connection-status').text()).toEqual oldValue

        @newValue = 'connection established'
        @board.set(modelProperty, @newValue)

      it 'the message is visible', =>
        expect(@boardView.$('#connection-status-modal')).toBeVisible()

      it 'the message is displayed', =>
        expect(@boardView.$('#connection-status').text()).toEqual @newValue

    describe 'when a status is unset', =>
      beforeEach =>
        modelProperty = 'status'

        oldValue = @board.get(modelProperty)
        expect(@boardView.$('#connection-status').text()).toEqual oldValue

        @newValue = null
        @board.set(modelProperty, @newValue)

      it 'the message is hidden', =>
        expect(@boardView.$('#connection-status-modal')).toBeHidden()

      it 'the message is empty', =>
        expect(@boardView.$('#connection-status').text()).toBeFalsy()

  #   it 'redisplays when a card moves between groups', =>
  #     expect(true).toEqual false
      
  #   #drag n drop
  #   # it 'creates a new group when a card is drops onto the board' 

  #   it 'redisplays when a group is added', =>
  #     expect(true).toEqual false
      
  #   it 'redisplays when a group is removed', =>
  #     expect(true).toEqual false

  describe 'hi event', =>
    beforeEach =>

    describe 'dblclick', =>
      beforeEach =>

      # it 'adds a new group with 1 card to the board', =>
        # expect(@card.get('text')).toEqual @newText
        # expect(@cardView.$('textarea').val()).toEqual @newText
        # expect(true).toEqual false


  #   @socket = new io.Socket
  #   @board = new boardroom.models.Board
  #     groups: [new boardroom.models.Group]
  #     users: {}
  #     user_id: 1
  #   @boardView = new boardroom.views.Board
  #     model: @board

  # describe 'set status', ->
  #   it 'shows the status', ->
  #     @board.set 'status', 'foo'
  #     expect(@boardView.statusModalDiv()).toBeVisible()
  #     expect(@boardView.statusDiv().html()).toEqual 'foo'

  # describe 'clear status', ->
  #   it 'hides the status', ->
  #     @board.set 'status', 'foo'
  #     @board.set 'status', null
  #     expect(@boardView.statusModalDiv()).toBeHidden()
  #     expect(@boardView.statusDiv().html()).toEqual ''

  # describe 'double click', ->
  #   beforeEach ->
  #     dblclick = new $.Event 'dblclick'
  #     dblclick.pageX = 200
  #     dblclick.pageY = 201
  #     @boardView.$el.trigger dblclick
  #     @pendingGroups = @board.get 'pendingGroups'

  #   it 'creates a new pending group', ->
  #     expect(@pendingGroups).toBeDefined()
  #     expect(@pendingGroups.length).toEqual(1)
  #     group = @pendingGroups.at(0)
  #     expect(group.get('cards').length).toEqual(0)
  #     expect(group.get('x')).toEqual(190)
  #     expect(group.get('y')).toEqual(191)

  # describe 'socket events', ->
  #   xdescribe 'card.delete', ->
  #     beforeEach ->
  #       @card = { _id: 1 }
  #       @cardCount = @boardView.$('.card').length
  #       @socket.emit 'card.create', @card
  #       @socket.emit 'card.delete', @card._id

  #     it 'removes the card', ->
  #       expect(@boardView.$('.card').length).toEqual @cardCount

  #   describe 'update events', ->
  #     beforeEach ->
  #       @card = { _id: 1}
  #       @group = {_id: 2, cards: [@card]}
  #       @socket.emit 'group.create', @group

  #     describe 'card.update (text)', ->
  #       beforeEach ->
  #         @text = 'updated text'
  #         @socket.emit 'card.update', { _id: @card._id, text: @text }

  #       it 'updates the card text', ->
  #         cardView = @boardView.findView 1
  #         expect(cardView.$('textarea')).toHaveValue(@text)

  #     describe 'card.update (color)', ->
  #       beforeEach ->
  #         @socket.emit 'card.update', { _id: @card._id, colorIndex: 0 }

  #       it 'updates the card color', ->
  #         cardView = @boardView.findView 1
  #         expect(cardView.$el).toHaveClass "color-0"

  # describe 'when clicking the add card button of a group', ->
  #   beforeEach ->
  #     @spy = sinon.spy()
  #     @cards = [{_id: 1}, { _id: 2}]
  #     @group = {_id: 2, x: 100, y: 200, cards: @cards}
  #     @socket.emit 'group.create', @group
  #     @socket.on 'group.card.create', @spy

  #   it 'creates a new card in the group', ->
  #     groupView = @boardView.findView(@group._id)
  #     @click = new $.Event 'click'
  #     groupView.$('.add-card').trigger @click
  #     expect(@spy.called).toBeTruthy()
