Factory = require './../support/factories'
Board = require "#{__dirname}/../../../lib/models/board"
Card = require "#{__dirname}/../../../lib/models/card"

describe 'board.Board', ->
  beforeEach (done) ->
    Board.remove ->
      Card.remove done

  describe '.all', ->
    describe 'given some boards', ->
      beforeEach (done) ->
        Factory.create 'board', ->
          Factory.create 'board', ->
            done()

      it 'finds all boards', (done) ->
        Board.all (error, boards) ->
          done error if error?
          expect(boards.length).toEqual 2
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
