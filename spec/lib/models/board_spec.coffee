Factory = require './../support/factories'
Board = require "#{__dirname}/../../../lib/models/board"
Card = require "#{__dirname}/../../../lib/models/card"

describe 'board.Board', ->
  beforeEach (done) ->
    Board.remove ->
      Card.remove done

  describe '.all', ->
    describe 'given deleted and non-deleted boards', ->
      beforeEach (done) ->
        Factory.create 'board', ->
          Factory.create 'board', deleted: undefined, ->
            Factory.create 'deletedBoard', ->
              done()

      it 'finds all non-deleted boards', (done) ->
        Board.all (boards) ->
          expect(boards.length).toEqual 2
          for board in boards
            expect(board.deleted).toBeFalsy()
          done()

  describe '.findByName', ->
    describe 'by default', ->
      name = 'name-1'

      beforeEach (done) ->
        Factory.create 'board', name: name, ->
          done()

      it 'finds a board by name', (done) ->
        Board.findByName name, (error, board) ->
          done error if error?
          expect(board.name).toEqual(name)
          done()

    describe 'when unable to find the board', ->
      it 'yields an error', (done) ->
        Board.findByName '', (error, board) ->
          expect(error).not.toBeUndefined()
          expect(error.message).toEqual 'board not found'
          expect(board).toBeUndefined()
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
        Factory.create 'card', boardName: board.name, ->
          Factory.create 'card', boardName: board.name, ->
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
