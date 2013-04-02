{ Factory, Card } = require "../support/model_test_support"

describe 'card.Card', ->
  describe '.findByGroupId', ->
    beforeEach (next) =>
      Factory 'group', (err, @group) =>
        Factory 'card', groupId: @group.id, ->
          next()

    it 'finds all cards for the given group', =>
      Card.findByGroupId @group.id, (err, cards) ->
        expect(cards.length).toEqual 1

  describe '#updateAttributes', ->
    describe 'by default', ->
      beforeEach ->
        @card = Factory.sync 'card'

      it 'updates its attributes', ->
        numAuthors = @card.authors.length
        numPlusAuthors = @card.plusAuthors.length
        attributes =
          text: "#{@card.text}-updated"
          colorIndex: @card.colorIndex + 1
          deleted: ! @card.deleted
          authors: [ @card.authors... ,  'author1' ]
          plusAuthors: [ @card.plusAuthors... , 'plusAuthor1']
        @card.sync.updateAttributes attributes
        card = Card.sync.findById @card.id
        expect(card.text).toEqual attributes.text
        expect(card.colorIndex).toEqual attributes.colorIndex
        expect(card.authors.length).toEqual numAuthors+1
        expect(card.plusAuthors.length).toEqual numPlusAuthors+1
