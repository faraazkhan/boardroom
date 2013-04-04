{ Factory, Board, Group, Card, async } = require "../support/model_test_support"

describe 'board.Board', ->
  describe '.createdBy', ->
    beforeEach (done) ->
      Factory.createBundle done

    it 'finds boards I created', (done) ->
      Board.createdBy 'board-creator-1', (err, boards) ->
        expect(boards.length).toEqual 1
        expect(boards[0].name).toEqual 'board1'
        expect(boards[0].groups.length).toEqual 1
        expect(boards[0].groups[0].cards.length).toEqual 1
        done()

  describe '.collaboratedBy', ->
    beforeEach (done) ->
      Factory.createBundle done

    it 'finds boards i collaborated on', (done) ->
      Board.collaboratedBy 'board-creator-1', (err, boards) ->
        expect(boards.length).toEqual 2
        names = (board.name for board in boards)
        expect(names[0]).toEqual 'board2'
        expect(names[1]).toEqual 'board3'
        done()

  describe '#lastUpdated', ->
    beforeEach (done) =>

      createBoard = (done) =>
        Factory "board", (err, board) =>
          @board = board
          done()

      createGroup = (done) =>
        Factory "group", boardId: @board.id, (err, group) =>
          @group = group
          done()

      createCard = (done) =>
        Factory "card", groupId: @group.id, (err, card) =>
          @card = card
          done()

      async.series [createBoard, createGroup, createCard], done

    it 'returns last updated of cards', (done) =>
      @card.save (err) =>
        Board.findById @board.id, (err, board) =>
          expect(board.lastUpdated().getTime()).toEqual @card.updated.getTime()
          done()

    it 'returns last updated of board', (done) =>
      @board.save (err) =>
        Board.findById @board.id, (err, board) =>
          expect(board.lastUpdated().getTime()).toEqual @board.updated.getTime()
          done()

  describe '#remove', ->
    beforeEach (done) =>
      createBoard = (done) =>
        Factory "board", (err, board) =>
          @board = board
          done()

      createGroup = (done) =>
        Factory "group", boardId: @board.id, (err, group) =>
          @group = group
          done()

      createCard = (done) =>
        Factory "card", groupId: @group.id, (err, card) =>
          @card = card
          done()

      async.series [ createBoard, createGroup, createCard, createCard ], done

    it 'removes the board', (done) =>
      @board.remove (err) ->
        count = Board.count {}, (err, count) ->
          expect(count).toEqual 0
          done()

    it "removes the board's groups", (done) =>
      @board.remove (err) ->
        count = Group.count {}, (err, count) ->
          expect(count).toEqual 0
          done()

    it "removes the board's cards", (done) =>
      @board.remove (err) ->
        count = Card.count {}, (err, count) ->
          expect(count).toEqual 0
          done()
