describe 'boardroom.views.Board', =>
  beforeEach =>
    # Start the board with 2 groups and 2 cards (1 card in each group)
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

    describe 'when a group is added', =>
      beforeEach =>
        @numGroups = $('.group').length
        @numCards = $('.card').length

        cardData = _id: 'c77', text: 'add77', authors: ['@card_adder'], colorIndex: 2, x: 120, y: 125
        groupData = _id: 'gnew', cards: [ cardData ]

        group = new boardroom.models.Group groupData
        # group.set 'board', @board, { silent: true } # !!! smelly
        @board.groups().add group

      it 'displays the new group and its cards', =>
        expect($('.group').length).toEqual @numGroups + 1
        expect($('.card').length).toEqual @numCards + 1

    describe 'when a group is removed', =>
      beforeEach =>
        @numGroups = $('.group').length
        @numCards = $('.card').length

        @board.groups().remove group2

      it 'undisplays the deleted group and its cards', =>
        expect($('.group').length).toEqual @numGroups - 1
        expect($('.card').length).toEqual @numCards - 1


  describe 'hi event', =>

    describe 'dblclick', =>
      beforeEach =>
        @numGroups = $('.group').length
        @numCards = $('.card').length

        e = new jQuery.Event("dblclick")
        e.pageX = 2000
        e.pageY = 2000
        @boardView.$el.trigger(e)

      it 'adds a new group with 1 card', =>
        expect($('.group').length).toEqual numGroups + 1
        # expect($('.card').length).toEqual numCards + 1  <--- does it make sense ato see this also work ?

