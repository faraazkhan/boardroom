describe 'boardroom.models.Card', ->
  describe '#idAttribute', ->
    beforeEach ->
      @card = new boardroom.models.Card

    it 'uses a MongoDB id attribute name', ->
      expect(@card.idAttribute).toEqual '_id'

  describe '#initialize', ->
    beforeEach ->
      @card = new boardroom.models.Card

    it 'default its text to an empty string', ->
      expect(@card.get('text')).toEqual ''
