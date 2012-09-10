{ Board } = require "#{__dirname}/../../../app/server/models/board"
{ Card } = require "#{__dirname}/../../../app/server/models/card"
Factory = require 'factory-lady'

Factory.define 'board', Board,
  name: 'name-1'
  creator_id: 'creator-1'
  deleted: false

Factory.define 'card', Card,
  boardName: 'name-1'
  author: 'author-1'
  x: 100
  y: 100
  text: 'text'
  deleted: false
  authors: ['author-2']

describe 'card.Card', ->
  beforeEach (done) ->
    Card.remove done

  describe '.findByBoardName', ->
    board = null
    beforeEach (done) ->
      Factory.create 'board', (defaultBoard) ->
        board = defaultBoard
        Factory.create 'card', boardName: board.name, ->
          done()

    it 'finds all cards for the given board', (done) ->
      Card.findByBoardName board.name, (cards) ->
        expect(cards.length).toEqual 1
        done()

  describe '.countsByBoard', ->
    board = null
    beforeEach (done) ->
      Factory.create 'board', (defaultBoard) ->
        board = defaultBoard
        Factory.create 'card', boardName: board.name, ->
          done()

    it 'returns the number of cards by board', (done) ->
      Card.countsByBoard (counts) ->
        Card.findByBoardName board.name, (cards) ->
          expect(cards.length).toEqual counts[board.name]
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
          colorIndex: "#{card.colorIndex}-updated"
          deleted: ! card.deleted
        card.updateAttributes attributes, ->
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
