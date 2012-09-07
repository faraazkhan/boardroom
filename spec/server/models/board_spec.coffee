{ Board } = require "#{__dirname}/../../../app/server/models/board"
Factory = require 'factory-lady'
_ = require 'underscore'

Factory.define 'board', Board,
  name: 'name-1'
  deleted: true
Factory.define 'deletedBoard', Board,
  name: 'name-1'
  deleted: false

describe 'board.Board', ->
  beforeEach (done) ->
    Board.remove done

  describe '#findBoards', ->
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
