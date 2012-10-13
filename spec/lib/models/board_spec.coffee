{ Factory, Board, Card } = require "../support/model_test_support"

describe 'board.Board', ->
  describe '.createdBy', ->
    beforeEach ->
      Factory.sync.createBundle()

    it 'finds boards I created', ->
      boards = Board.sync.createdBy 'board-creator-1'
      expect(boards.length).toEqual 1
      expect(boards[0].name).toEqual 'board1'
      expect(boards[0].cards.length).toEqual 1

  describe '.collaboratedBy', ->
    beforeEach ->
      Factory.sync.createBundle()

    it 'finds boards i collaborated on', ->
      boards = Board.sync.collaboratedBy 'board-creator-1'
      expect(boards.length).toEqual 2
      names = (board.name for board in boards)
      expect(names[0]).toEqual 'board2'
      expect(names[1]).toEqual 'board3'

  describe '#lastUpdated', ->
    beforeEach ->
      @board = Factory.sync.create 'board'
      @card = Factory.sync.create 'card', boardId: @board.id

    it 'returns last updated of cards', ->
      @card.sync.save()
      board = Board.sync.findById @board.id
      expect(board.lastUpdated().getTime()).toEqual @card.updated.getTime()

    it 'returns last updated of board', ->
      @board.sync.save()
      board = Board.sync.findById @board.id
      expect(board.lastUpdated().getTime()).toEqual @board.updated.getTime()

  describe '#destroy', ->
    beforeEach ->
      @board = Factory.sync.create 'board'
      Factory.sync.create 'card', boardId: @board.id
      Factory.sync.create 'card', boardId: @board.id

    it 'removes the board', ->
      @board.sync.destroy()
      count = Board.sync.count {}
      expect(count).toEqual 0

    it "removes the board's cards", ->
      @board.sync.destroy()
      count = Card.sync.count {}
      expect(count).toEqual 0
