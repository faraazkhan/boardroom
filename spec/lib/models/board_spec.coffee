{ Factory, Board, Card } = require "../support/model_test_support"

describe 'board.Board', ->
  describe '.createdBy', ->
    beforeEach (done) ->
      Factory.createBundle 'typical', ->
        done()

    it 'finds boards i created', (done) ->
      Board.createdBy 'board-creator-1', (error, boards) ->
        done error if error?
        expect(boards.length).toEqual 1
        expect(boards[0].name).toEqual 'board1'
        expect(boards[0].cards.length).toEqual 1
        done()

  describe '.collaboratedBy', ->
    beforeEach (done) ->
      Factory.createBundle 'typical', ->
        done()

    it 'finds boards i collaborated on', (done) ->
      Board.collaboratedBy 'board-creator-1', (error, boards) ->
        done error if error?
        expect(boards.length).toEqual 2
        names = boards.map (board) ->
          board.name
        expect(names[0]).toEqual 'board2'
        expect(names[1]).toEqual 'board3'
        done()

  describe '#lastUpdated', ->
    board = card = null
    beforeEach (done) ->
      Factory.create 'board', (defaultBoard) ->
        board = defaultBoard
        Factory.create 'card', boardId: board.id, (defaultCard) ->
          card = defaultCard
          done()

    it 'returns last updated of cards', (done) ->
      card.save (error, card) ->
        Board.findById board.id, (error, board) ->
          expect(board.lastUpdated().getTime()).toEqual card.updated.getTime()
          done()

    it 'returns last updated of board', (done) ->
      board.save (error, board) ->
        Board.findById board.id, (error, board) ->
          expect(board.lastUpdated().getTime()).toEqual board.updated.getTime()
          done()

  describe '#addGroup', ->
    board = null
    beforeEach (done) ->
      Factory.create 'board', (defaultBoard) ->
        board = defaultBoard
        done()

    it 'adds a new group to its groups', (done) ->
      attributes =
        name: 'group-1'
      board.addGroup attributes, ->
        expect(board._id).toBeNull()
        expect(board.groups.length).toEqual 1
        [group] = board.groups
        expect(group.name).toEqual(attributes.name)
        done()

  describe '#destroy', ->
    board = null
    beforeEach (done) ->
      Factory.create 'board', (defaultBoard) ->
        board = defaultBoard
        Factory.create 'card', boardId: board.id, ->
          Factory.create 'card', boardId: board.id, ->
            done()

    it 'removes the board', (done) ->
      board.destroy (error) ->
        done error if error?
        Board.count {}, (error, count) ->
          done error if error?
          expect(count).toEqual 0
          done()

    it 'removes the board\'s cards', (done) ->
      board.destroy (error) ->
        done error if error?
        Card.count {}, (error, count) ->
          done error if error?
          expect(count).toEqual 0
          done()
