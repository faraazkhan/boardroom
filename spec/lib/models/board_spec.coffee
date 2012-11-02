{ Factory, Board, Group, Card } = require "../support/model_test_support"

describe 'board.Board', ->
  describe '.createdBy', ->
    beforeEach ->
      Factory.sync.createBundle()

    it 'finds boards I created', ->
      boards = Board.sync.createdBy 'board-creator-1'
      expect(boards.length).toEqual 1
      expect(boards[0].name).toEqual 'board1'
      expect(boards[0].groups.length).toEqual 1
      expect(boards[0].groups[0].cards.length).toEqual 1

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
      @board = Factory.sync 'board'
      @group = Factory.sync 'group', boardId: @board.id
      @card = Factory.sync 'card', groupId: @group.id

    it 'returns last updated of cards', ->
      @card.sync.save()
      board = Board.sync.findById @board.id
      expect(board.lastUpdated().getTime()).toEqual @card.updated.getTime()

    it 'returns last updated of board', ->
      @board.sync.save()
      board = Board.sync.findById @board.id
      expect(board.lastUpdated().getTime()).toEqual @board.updated.getTime()

  describe '#remove', ->
    beforeEach ->
      @board = Factory.sync 'board'
      @group = Factory.sync 'group', boardId: @board.id
      Factory.sync 'card', groupId: @group.id
      Factory.sync 'card', groupId: @group.id

    it 'removes the board', ->
      @board.sync.remove()
      count = Board.sync.count {}
      expect(count).toEqual 0

    it "removes the board's groups", ->
      @board.sync.remove()
      count = Group.sync.count {}
      expect(count).toEqual 0

    it "removes the board's cards", ->
      @board.sync.remove()
      count = Card.sync.count {}
      expect(count).toEqual 0
