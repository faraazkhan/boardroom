{ Factory, Board, Card } = require "../support/model_test_support"

describe 'card.Card', ->
  describe '.findByBoardId', ->
    beforeEach ->
      @board = Factory.sync.create 'board'
      Factory.sync.create 'card', boardId: @board.id

    it 'finds all cards for the given board', ->
      cards = Card.sync.findByBoardId @board.id
      expect(cards.length).toEqual 1

  describe '#updateAttributes', ->
    describe 'by default', ->
      beforeEach ->
        @card = Factory.sync.create 'card'

      it 'updates its attributes', ->
        attributes =
          x: @card.x + 1
          y: @card.y + 1
          text: "#{@card.text}-updated"
          colorIndex: @card.colorIndex + 1
          deleted: ! @card.deleted
        @card.sync.updateAttributes attributes
        card = Card.sync.findById @card.id
        expect(card.x).toEqual attributes.x
        expect(card.y).toEqual attributes.y
        expect(card.text).toEqual attributes.text
        expect(card.colorIndex).toEqual attributes.colorIndex
        expect(card.deleted).toEqual attributes.deleted

    describe 'given a new author to the card', ->
      beforeEach ->
        @card = Factory.sync.create 'card'

      it 'adds them to its authors', ->
        attributes =
          authors: [
            "#{@card.creator}-author-1"
            "#{@card.creator}-author-2"
          ]
        count = @card.authors.length
        @card.sync.updateAttributes attributes
        expect(@card.authors.length).toEqual count + 2
