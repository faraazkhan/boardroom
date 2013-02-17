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
      @groupCount = @board.groups().length
      @board.createGroup { x: 50, y: 50 }

    it 'creates a new group with a cid but no id', ->
      expect(@board.groups().length).toEqual @groupCount + 1
      group = @board.groups().at(@groupCount)
      expect(group.cid).toBeDefined()
      expect(group.id).toBeUndefined()

  describe '#mergeGroups', ->

  describe '#dropCard', ->

  describe '#dropGroup', ->
