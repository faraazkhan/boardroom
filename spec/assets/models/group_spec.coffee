describe 'boardroom.models.Group', ->
  beforeEach ->
    @group = new boardroom.models.Group
      cards: [ { _id: 1 }, { _id: 2 } ]

  describe '#findCard', ->
    it 'finds the card', ->
      @card = @group.findCard 2
      expect(@card).toBeDefined()
      expect(@card.id).toEqual 2
