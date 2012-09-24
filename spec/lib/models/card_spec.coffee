Factory = require './../support/factories'
Board = require "#{__dirname}/../../../lib/models/board"
Card = require "#{__dirname}/../../../lib/models/card"

describe 'card.Card', ->
  beforeEach (done) ->
    Board.remove ->
      Card.remove done

  describe '.findByBoardId', ->
    board = null
    beforeEach (done) ->
      Factory.create 'board', (defaultBoard) ->
        board = defaultBoard
        Factory.create 'card', boardId: board.id, ->
          done()

    it 'finds all cards for the given board', (done) ->
      Card.findByBoardId board.id, (error, cards) ->
        done error if error?
        expect(cards.length).toEqual 1
        done()

  describe '.countsByBoard', ->
    board = null
    beforeEach (done) ->
      Factory.create 'board', (defaultBoard) ->
        board = defaultBoard
        Factory.create 'card', boardId: board.id, ->
          done()

    it 'returns the number of cards by board', (done) ->
      Card.countsByBoard (counts) ->
        Card.findByBoardId board.id, (error, cards) ->
          done error if error?
          expect(cards.length).toEqual counts[board.id]
          done()

  describe '#updateAttributes', ->
    card = null

    describe 'by default', ->
      beforeEach (done) ->
        Factory.create 'card', (defaultCard) ->
          card = defaultCard
          done()

      it 'updates its attributes', (done) ->
        attributes =
          x: card.x + 1
          y: card.y + 1
          text: "#{card.text}-updated"
          colorIndex: card.colorIndex + 1
          deleted: ! card.deleted
        card.updateAttributes attributes, ->
          Card.findById card.id, (error, card) ->
            done error if error?
            expect(card.x).toEqual attributes.x
            expect(card.y).toEqual attributes.y
            expect(card.text).toEqual attributes.text
            expect(card.colorIndex).toEqual attributes.colorIndex
            expect(card.deleted).toEqual attributes.deleted
            done()

    describe 'given a new contributor to the card', ->
      beforeEach (done) ->
        Factory.create 'card', (defaultCard) ->
          card = defaultCard
          done()

      it 'adds them to its authors', (done) ->
        attributes =
          authors: [
            "#{card.author}-contributor-1"
            "#{card.author}-contributor-2"
          ]
        authorsCount = card.authors.length
        card.updateAttributes attributes, ->
          expect(card.authors.length).toEqual authorsCount + 2
          done()
