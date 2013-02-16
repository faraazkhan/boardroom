describe 'boardroom.models.Board', ->
  beforeEach ->
    group1 = { _id: '1', cards: [ { _id: '11' }, { _id: '12' } ] }
    group2 = { _id: '2', cards: [ { _id: '21' }, { _id: '22' } ] }
    @board = new boardroom.models.Board
      user_id: '@foo'
      groups: [ group1, group2 ]

  describe '#addUser', ->
    beforeEach ->
      @user = { user_id: '@bar' }
      @board.addUser @user

    it 'adds the user to its users', ->
      expect(@board.get('users')[@user.user_id]).toEqual @user

  describe '#findGroup', ->
    it 'finds the group', ->
      group = @board.findGroup '2'
      expect(group).toBeDefined()
      expect(group.id).toEqual '2'

  describe '#findCard', ->
    it 'finds the card', ->
      card = @board.findCard '22'
      expect(card).toBeDefined()
      expect(card.id).toEqual '22'

  describe '#createGroup', ->
    beforeEach ->
      @board.createGroup { x: 50, y: 50 }

    it 'creates a new pending group', ->
      expect(@board.pendingGroups().length).toEqual 1

    describe 'and receive the created group from the server', ->
      beforeEach ->
        pendingGroup = @board.pendingGroups().at(0)
        @board.groups().add new boardroom.models.Group
          _id: '3'
          x: pendingGroup.get 'x'
          y: pendingGroup.get 'y'
          z: pendingGroup.get 'z'
        @group = @board.findGroup '3'
        expect(@group).toBeDefined()

      it 'creates a new card in that group', ->
        expect(@group.pendingCards().length).toEqual 1
        card = @group.pendingCards().at(0)
        expect(card.get('groupId')).toEqual '3'
        expect(card.get('creator')).toEqual @board.currentUser()
        expect(card.get('authors')).toEqual [ @board.currentUser() ]

      it 'removes the pending group', ->
        expect(@board.pendingGroups().length).toEqual 0


  describe '#mergeGroups', ->

  describe '#dropCard', ->

  describe '#dropGroup', ->
