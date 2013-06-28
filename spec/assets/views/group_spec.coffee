###
# Gropu View
# A group view is always rendered inside a board view
###

describe 'boardroom.views.Group', =>
  beforeEach =>
    setFixtures '''
      <html><body>
      <div class="board" style="width:3000px; height:3000px">
        <div id="connection-status-modal">
          <div id="connection-status"></div>
        </div>
      </div>
      </body></html>
    '''
    @userIdentity0 = {userId:"board_maker",  username:"board_maker", displayName:"Board Maker", email:"board_maker@gmail.com", source:"google", avatar:"http://www.me.com/pic0"}
    @userIdentity1 = {userId:"card_maker_1", username:"card_maker", displayName:"Card Maker 1", email:"card_maker_1@gmail.com", source:"google", avatar:"http://www.me.com/pic1"}
    @userIdentity2 = {userId:"card_maker_2", username:"card_maker", displayName:"Card Maker 2", email:"card_maker_2@gmail.com", source:"google", avatar:"http://www.me.com/pic2"}
    userIdentitySet = {}
    userIdentitySet["#{@userIdentity0.userId}"] = @userIdentity0
    userIdentitySet["#{@userIdentity1.userId}"] = @userIdentity1
    userIdentitySet["#{@userIdentity2.userId}"] = @userIdentity2

    card1Data = {_id: '3', text: 'foo', authors: [@userIdentity1.userId], colorIndex: 1, x: 20, y: 25}
    card2Data = {_id: '4', text: 'bar', authors: [@userIdentity2.userId], colorIndex: 1, x: 40, y: 45}
    cards = [ card1Data, card2Data ]
    groups = [ { _id: '2', x: 20, y: 25, z:1, cards } ]
    boardData =  { _id: '1', currentUserId: @userIdentity0.userId, creator: @userIdentity0.userId, userIdentitySet, groups }

    # initialize the board
    @board = new boardroom.models.Board boardData
    @boardView = new boardroom.views.Board
      model: @board

    # Grab a reference to the card model and View for testing
    @groupView = @boardView.groupViews[0]
    @cardView = @groupView.cardViews[0]
    @cardView2 = @groupView.cardViews[1]
    @group = @groupView.model

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
      expect($('.board').length).toEqual 1
      expect($('.group').length).toEqual 1
      expect($('.card').length).toEqual 2

    it 'redisplays when name changes', (done)=>
      modelProperty = 'name'

      oldValue = @card.get(modelProperty) || ''
      expect(@groupView.$('input.name').val()).toEqual oldValue

      newValue = 'My Group Name' + (new Date).getTime()
      @group.set(modelProperty, newValue)
      expect(@groupView.$('input.name').val()).toEqual newValue

    it 'redisplays when there is a hover', (done)=>
      modelProperty = 'hover'

      oldValue = @group.get(modelProperty)
      expect(@groupView.$el.attr("class")).toEqual 'group'

      newValue = true
      @group.set(modelProperty, newValue)
      expect(@groupView.$el).toHaveClass 'stackable'

    it 'moves when x and y change', (done)=>
      oldXValue = @group.get('x')
      oldYValue = @group.get('y')
      expect(@groupView.$el.offset().left).toEqual oldXValue
      expect(@groupView.$el.offset().top).toEqual oldYValue

      x = 200
      y = 300
      @group.set {x, y}
      expect(@groupView.$el.offset().left).toEqual x
      expect(@groupView.$el.offset().top).toEqual  y

    it 'redisplays when z changes', (done)=>
      modelProperty = 'z'

      oldValue = @group.get(modelProperty)
      expect(@groupView.$el.css("z-index")).toEqual "#{oldValue}"

      newValue = oldValue + 2
      @group.set(modelProperty, newValue)
      expect(@groupView.$el.css("z-index")).toEqual "#{newValue}"

  describe 'hi event', =>

    describe 'typing a new name', =>
      beforeEach =>
        @newText = 'group-' + (new Date).getTime()
        @groupView.$('input.name').val(@newText).trigger('keyup')

      it 'changes text', =>
        expect(@group.get('name')).toEqual @newText
        expect(@groupView.$('input.name').val()).toEqual @newText

    describe 'clicking the add-card button', =>
      beforeEach =>
        @cardCount = $('.card').length
        @groupView
          .$(".add-card")
          .click()

      it 'adds a new card to the group', =>
        expect($('.card').length).toEqual @cardCount + 1
