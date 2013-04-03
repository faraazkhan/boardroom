{ Factory, Board, LoggedInRouter, request, jsdom, url, $, async } =
  require '../support/controller_test_support'

BoardsController = require '../../../lib/controllers/boards'

describe 'BoardsController', ->
  describe '#create', ->
    beforeEach ->
      @router = new LoggedInRouter
      @name = 'name-1'

    it 'creates a default board and redirects to it', (done)->
      response = null

      makeRequest = (next)=>
        request(@router.app)
          .post('/boards')
          .send(name: @name)
          .end (req, res)->
            response = res
            expect(res.redirect).toBeTruthy()
            next()

      countBoards = (next)=>
        Board.count {}, (err, count)->
          expect(count).toEqual 1
          next()

      findDefaultBoard = (next)=>
        Board.findOne { creator: @router.user }, (err, board)=>
          redirect = url.parse response.headers.location
          expect(redirect.path).toEqual "/boards/#{board.id}"
          expect(board.name).toEqual @name
          next()

      async.series [ makeRequest, countBoards, findDefaultBoard ], (err, result)->
        done()

  describe '#show', ->
    beforeEach =>
      @router = new LoggedInRouter

    describe 'given an existing board id', =>
      beforeEach (done) =>
        Factory "board", (err, board) =>
          @id = board.id
          done()

      it 'returns the board page', (done) =>
        response = request(@router.app)
          .get("/boards/#{@id}")
          .end (req, res) ->
            expect(res.statusCode).toBe(200)
            done()

  describe '#destroy', ->

    beforeEach (done) =>
      @router = new LoggedInRouter
      Factory "board", (err, board) =>
        @board = board
        done()

    it 'deletes the board', (done) =>
      request(@router.app)
        .post("/boards/#{@board.id}")
        .end (err, response) =>
          expect(response.redirect).toBeTruthy()
          redirect = url.parse response.headers.location
          expect(redirect.pathname).toEqual '/'
          Board.findById @board.id, (err, board) ->
            expect(board).toBeNull()
            done()

  describe '#build', ->
    beforeEach (done) =>
      @name = 'name-1'
      @creator = 'board-creator-1'
      boardsController = new BoardsController
      boardsController.build @name, @creator, (board) ->
        done()

    it 'creates a new board', (done) =>
      countBoards = (next) ->
        Board.count (err, count) =>
          expect(count).toEqual 1
          next(null)

      findFirstBoard = (next) ->
        Board.findOne {}, (err, board) =>
          next(null, board.id)

      findBoardById = (id, next) =>
        Board.findById id, (err, board) =>
          board = board.toObject getters: true
          next(null, board)

      assertOwnership = (board, next) =>
        expect(board.name).toEqual @name
        expect(board.creator).toEqual @creator
        expect(board.groups[0].cards.length).toEqual 1

        card = board.groups[0].cards[0]
        expect(card.creator).toEqual @creator
        expect(card.authors[0]).toEqual '@carbonfive'
        expect(card.text).toContain 'Welcome to your virtual whiteboard!'
        next(null)

      async.waterfall [ countBoards, findFirstBoard, findBoardById, assertOwnership ], done
