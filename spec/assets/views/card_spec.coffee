###
# Card View
# A cardView is always rendered inside a groupView
###

describe 'boardroom.views.Card', =>
  beforeEach =>
    setFixtures '''
      <html><body>
      <div class="board">
        <div id="connection-status-modal">
          <div id="connection-status"></div>
        </div>
      </div>
      </body></html>
    '''
    boardData =
      _id: '1'
      user_id: '@carbon_five'
      groups: [
        {
          _id: '2'
          cards: [
            {
              _id: '3'
              text: 'foo'
              authors: ['@card_maker']
              colorIndex: 1
            },
            {
              _id: '4'
            }
          ]
        }
      ]

    # initialize the board
    @board = new boardroom.models.Board boardData
    @boardView = new boardroom.views.Board
      model: @board

    # Grab a reference to the card model and View for testing
    @groupView = @boardView.groupViews[0]
    @cardView = @groupView.cardViews[0]
    @cardView2 = @groupView.cardViews[1]
    @group = @groupView.model
    @card = @cardView.model
    @card2 = @cardView2.model

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
      expect($('.card').length).toEqual 2

    it 'redisplays when color changes', (done)=>
      modelProperty = 'colorIndex'

      oldValue = @card.get(modelProperty)
      expect(@cardView.$el).toHaveClass "color-#{oldValue}"

      newValue = oldValue+1
      @card.set(modelProperty, newValue)
      expect(@cardView.$el).toHaveClass "color-#{newValue}"

    it 'redisplays when text changes', =>
      modelProperty = 'text'

      oldValue = @card.get(modelProperty)
      expect(@cardView.$('textarea').val()).toEqual oldValue

      newValue = "#{oldValue} + more stuff"
      @card.set(modelProperty, newValue) 
      expect(@cardView.$('textarea').val()).toEqual newValue

    # use drag-n-drop testing for position changes
    # it 'repositions when x changes', =>
    # it 'repositions when y changes', =>

    it 'redisplays when +1 increments', =>
      modelProperty = 'plusAuthors'
      oldValue = @card.get(modelProperty)

      # test base case does not display + count for 0 likes
      @card.set(modelProperty, [])
      expect(@cardView.$('.plus-count').text()).toBe('')

      auths = @card.get(modelProperty)
      @card.set(modelProperty, ['liker1', auths...])
      expect(@cardView.$('.plus-count').text()).toBe("+#{auths.length + 1}")
      @card.set(modelProperty, ['liker2', auths...])
      expect(@cardView.$('.plus-count').text()).toBe("+#{auths.length + 1}") 
      @card.set(modelProperty, oldValue)

    it 'redisplays when there is a new contributor', =>
      modelProperty = 'authors'

      oldValue = @card.get(modelProperty)
      expect(@card.get('authors').length).toEqual oldValue.length

      newValue = ['@space_cadet',  oldValue...]
      @card.set(modelProperty, newValue) 
      expect(@card.get('authors').length).toEqual newValue.length

  describe 'hi event', =>

    describe 'typing a note', =>
      beforeEach =>
        @authorCount = @card.get('authors').length
        @newText = 'bar-' + (new Date).getTime()

        @cardView.$('textarea').val(@newText).trigger('keyup')

      it 'changes text', =>
        expect(@card.get('text')).toEqual @newText
        expect(@cardView.$('textarea').val()).toEqual @newText

      it 'touch', =>
        expect(@card.get('authors').length).toEqual @authorCount+1
        expect(@cardView.$('.authors').children().length).toEqual @authorCount+1

    describe 'clicking a color', =>
      beforeEach =>
        @authorCount = @card.get('authors').length
        @colorIndex = 3
        @cardView
          .$(".color-#{@colorIndex}")
          .click()

      it 'changes color', =>
        expect(@card.get('colorIndex')).toEqual "#{@colorIndex}"
        expect(@cardView.$el).toHaveClass "color-#{@colorIndex}"

      it 'touch', =>
        expect(@card.get('authors').length).toEqual @authorCount+1
        expect(@cardView.$('.authors').children().length).toEqual @authorCount+1

    describe 'clicking +1', =>
      beforeEach =>
        @authorCount = @card.get('authors').length
        @plusAuthorCount = @card.get('plusAuthors').length
        @cardView
          .$(".plus1 .btn")
          .click()

      it 'increments +1', =>
        expect(@card.get('plusAuthors').length).toEqual @plusAuthorCount+1
        expect(@cardView.$('.plus-count').text()).toBe("+#{@plusAuthorCount+1}")

      it 'does not touch', =>
        expect(@card.get('authors').length).toEqual @authorCount
        expect(@cardView.$('.authors').children().length).toEqual @authorCount

    describe 'clicking delete', =>
      beforeEach =>
        @cardView
          .$(".delete-btn")
          .click()

      it 'deletes the card', =>
        expect(@group.cards().length).toEqual 1
        expect(@groupView.cardViews.length).toEqual 1
        expect($("##{@card.get('_id')}").length).toEqual 0

      it 'does not delete the group', =>
        expect(@board.groups().length).toEqual 1
        expect(@boardView.groupViews.length).toEqual 1

      describe 'on the last card in a group', =>
        beforeEach =>
          @cardView2.$('.delete-btn').click()

        it 'deletes the group', =>
          expect(@board.groups().length).toEqual 0
          expect(@boardView.groupViews.length).toEqual 0
          expect($("##{@card2.get('_id')}").length).toEqual 0

