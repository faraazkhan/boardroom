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
    @board = new boardroom.models.Board
      id: 1
      user_id: 11
    @boardView = new boardroom.views.Board
      model: @board
    @group = new boardroom.models.Group
      id: 2
      board: @board
    @groupView = new boardroom.views.Group
      model: @group
      boardView: @boardView
    @card = new boardroom.models.Card
      id: 3
      group: @group
      authors: []
      plusAuthors: []
      text: 'foo'
      colorIndex: 1
    @cardView = new boardroom.views.Card
      model: @card
      groupView: @groupView
      boardView: @boardView
    $('.board').append @cardView.render()

  describe 'render event', =>
    it 'displays', =>
      # expect($('.card').length).toBeGreaterThan 0  -- Why doesn't the fixture work?
      expect(@cardView.$el.children().length).toBeGreaterThan 0
      
    it 'redisplays when color changes', =>
      oldColorIndex = @card.get('colorIndex')
      colorIndex = oldColorIndex+1
      expect(@cardView.$el).toHaveClass "color-#{oldColorIndex}"

      @card.set('colorIndex', colorIndex) # set the model
      expect(@cardView.$el).toHaveClass "color-#{colorIndex}" # expect the view to update

  #   xit 'redisplays when text changes', ->
  #   xit 'repositions when x changes', ->
  #   xit 'repositions when y changes', ->
  #   xit 'redisplays when +1 increments', ->
  #   xit 'redisplays when there is a new contributor', ->

  describe 'hi event', =>

    describe 'typing a note', =>
      beforeEach =>
        @authorCount = @card.get('authors').length
        @newText = 'bar-' + (new Date).getTime()

        @cardView.$('textarea').val(@newText).trigger('keyup')

      it 'changes text', =>
        expect(@card.get('text')).toEqual @newText

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

  #   describe 'clicking delete', =>
  #     beforeEach =>
  #       @authorCount = @card.get('authors').length
  #       @plusAuthorCount = @card.get('plusAuthors').length
  #       @cardView
  #         .$(".plus1 .btn")
  #         .click()

  #     it 'deletes the card', ->
  #       expect(@card.get('plusAuthors').length).toEqual @plusAuthorCount+1
  #       expect(@cardView.$('.plus-count').text()).toBe("+#{@plusAuthorCount+1}")
