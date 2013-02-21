{ Factory, Board, LoggedInRouter, request, jsdom, url, $ } =
  require '../support/controller_test_support'

BoardsController = require '../../../lib/controllers/boards'

describe 'BoardsController', ->
  describe '#create', ->
    beforeEach ->
      @router = new LoggedInRouter
      @name = 'name-1'

    it 'creates a default board and redirects to it', ->
      response = request(@router.app)
        .post('/boards')
        .send(name: @name)
        .sync
        .end()

      expect(response.redirect).toBeTruthy()

      boardCount = Board.sync.count()
      expect(boardCount).toEqual 1

      board = Board.sync.findOne { creator: @router.user }
      redirect = url.parse response.headers.location
      expect(redirect.path).toEqual "/boards/#{board.id}"
      expect(board.name).toEqual @name

  describe '#show', ->
    beforeEach ->
      @router = new LoggedInRouter

    describe 'given an existing board id', ->
      beforeEach ->
        @board = Factory.sync 'board'
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
      @board = Factory.sync 'board'

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

  describe '#build', ->
    beforeEach ->
      @name = 'name-1'
      @creator = 'board-creator-1'
      boardsController = new BoardsController
      boardsController.build @name, @creator

    it 'creates a new board', ->
      count = Board.sync.count()
      expect(count).toEqual 1

      board = Board.sync.findOne {}
      board = Board.sync.findById board.id
      board = board.toObject getters: true
      expect(board.name).toEqual @name
      expect(board.creator).toEqual @creator
      expect(board.groups[0].cards.length).toEqual 1

      card = board.groups[0].cards[0]
      expect(card.creator).toEqual @creator
      expect(card.authors[0]).toEqual '@carbonfive'
      expect(card.text).toContain 'Welcome to your virtual whiteboard!'

