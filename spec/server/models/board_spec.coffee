{ Board } = require "#{__dirname}/../../../app/server/models/board"
Factory = require 'factory-lady'
_ = require 'underscore'

Factory.define 'board', Board,
  name: 'name-1'
  creator_id: 'creator-1'
  deleted: false

Factory.define 'deletedBoard', Board,
  name: 'name-2'
  creator_id: 'creator-2'
  deleted: true

describe 'board.Board', ->
  beforeEach (done) ->
    Board.remove done

  describe '.findBoards', ->
    describe 'given deleted and non-deleted boards', ->
      beforeEach (done) ->
        Factory.create 'board', ->
          Factory.create 'deletedBoard', ->
            done()

      it 'finds all non-deleted boards', (done) ->
        Board.findBoards (boards) ->
          expect(boards.length).toEqual 1
          _.each boards, (board) ->
            expect(board.deleted).toBeFalsy()
          done()

  describe '.findByName', ->
    name = 'name-1'

    beforeEach (done) ->
      Factory.create 'board', name: name, ->
        done()

    it 'finds a board by name', (done) ->
      Board.findByName name, (board) ->
        expect(board.name).toEqual(name)
        done()

  describe '.findOrCreateByNameAndCreatorId', ->
    describe 'given an existing board', ->
      board = null
      beforeEach (done) ->
        Factory.create 'board', (existingBoard) ->
          board = existingBoard
          done()

      it 'finds the existing board', (done) ->
        Board.findOrCreateByNameAndCreatorId board.name,
          board.creator_id,
          (existingBoard) ->
            expect(existingBoard.name).toEqual(board.name)
            expect(existingBoard.creator_id).toEqual(board.creator_id)
            done()

    describe 'given no matching board', ->
      attributes =
        name: 'name-1'
        creator_id: 'creator-1'

      it 'creates a new board', (done) ->
        Board.findOrCreateByNameAndCreatorId attributes.name,
          attributes.creator_id,
          (board) ->
            expect(board).not.toBeUndefined()
            expect(board.name).toEqual(attributes.name)
            expect(board.creator_id).toEqual(attributes.creator_id)
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
        done()

    it 'marks itself as deleted', (done) ->
      board.destroy ->
        expect(board.deleted).toBeTruthy()
        Board.count {}, (_, count) ->
          expect(count).toEqual 1
          done()
