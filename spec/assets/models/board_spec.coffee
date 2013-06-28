describe 'boardroom.models.Board', ->
  beforeEach ->
    @userIdentity0 = {userId:"board_maker",  username:"board_maker", displayName:"Board Maker", email:"board_maker@gmail.com", source:"google", avatar:"http://www.me.com/pic0"}
    userIdentitySet = {}
    userIdentitySet["#{@userIdentity0.userId}"] = @userIdentity0

    group1 = { _id: '1', cards: [ { _id: '11' }, { _id: '12' } ] }
    group2 = { _id: '2', cards: [ { _id: '21' }, { _id: '22' } ] }
    @board = new boardroom.models.Board
      currentUserId: @userIdentity0.userId
      creator: @userIdentity0.userId
      userIdentitySet: userIdentitySet
      groups: [ group1, group2 ]

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
