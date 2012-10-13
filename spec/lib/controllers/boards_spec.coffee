{ Factory, Board, Card, LoggedInRouter, request, jsdom, url, $ } =
  require '../support/controller_test_support'

describe 'BoardsController', ->
  describe '#create', ->
    beforeEach ->
      @router = new LoggedInRouter

    it 'creates a new board', ->
      name = 'name-1'
      response = request(@router.app)
        .post('/boards')
        .send(name: name)
        .sync
        .end()
      count = Board.sync.count()
      expect(count).toEqual 1
      board = Board.sync.findOne {}
      expect(board.name).toEqual name
      expect(board.creator).toEqual 'user'

  describe '#show', ->
    beforeEach ->
      @router = new LoggedInRouter

    describe 'given an existing board id', ->
      beforeEach ->
        @board = Factory.sync.create 'board'
        @id = @board.id

      it 'returns the board page', ->
        response = request(@router.app)
          .get("/boards/#{@id}")
          .sync
          .end()
        expect(response.statusCode).toBe(200)

    describe 'given an unknown board id', ->
      beforeEach ->
        mongoose = require 'mongoose'
        @id = new mongoose.Types.ObjectId

      it 'returns a 404 code', ->
        response = request(@router.app)
          .get("/boards/#{@id}")
          .sync
          .end()
        expect(response.statusCode).toBe(404)

  describe '#destroy', ->
    beforeEach  ->
      @router = new LoggedInRouter
      @board = Factory.sync.create 'board'

    it 'deletes the board', ->
      response = request(@router.app)
        .post("/boards/#{@board.id}")
        .sync
        .end()
      expect(response.redirect).toBeTruthy()
      redirect = url.parse response.headers.location
      expect(redirect.pathname).toEqual '/'
      board = Board.sync.findById @board.id
      expect(board).toBeNull()
