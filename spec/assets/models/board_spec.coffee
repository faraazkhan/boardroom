describe 'boardroom.models.Board', ->
  beforeEach ->
    group1 = { _id: 1, cards: [ { _id: 11 }, { _id: 12 } ] }
    group2 = { _id: 2, cards: [ { _id: 21 }, { _id: 22 } ] }
    @board = new boardroom.models.Board
      groups: [ group1, group2 ]
      users: {}

  describe '#addUser', ->
    beforeEach ->
      @user =
        user_id: '1'

      @board.addUser @user

    it 'adds the user to its users', ->
      expect(@board.get('users')[@user.user_id]).toEqual @user

  describe '#findGroup', ->
    it 'finds the group', ->
      @group = @board.findGroup 2
      expect(@group).toBeDefined()
      expect(@group.id).toEqual 2

  describe '#findCard', ->
    it 'finds the card', ->
      @card = @board.findCard 22
      expect(@card).toBeDefined()
      expect(@card.id).toEqual 22
