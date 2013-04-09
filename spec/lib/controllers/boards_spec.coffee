{ Factory, Board, request, jsdom, url, $, async, describeController } =
  require '../support/controller_test_support'

BoardsController = require '../../../lib/controllers/boards'

describeController 'BoardsController', (session) ->
  describe '#create', ->
    name = 'name-1'
    response = undefined

    beforeEach (done) ->
      session.login()

      session.request()
        .post('/boards')
        .send({ name })
        .end (req, res)->
          response = res
          done()

    it 'creates a default board for the current user', (done)->
      Board.count {}, (err, count) ->
        expect(count).toEqual 1
        done()

    it 'redirects to the new board', (done)->
      expect(response).toBeDefined()
      expect(response.redirect).toBeTruthy()
      Board.findOne { creator: session.user }, (err, board) ->
        expect(board.name).toEqual name
        redirect = url.parse response.headers.location
        expect(redirect.path).toEqual "/boards/#{board.id}"
        done()

  describe '#show', ->
    id = undefined

    beforeEach ->
      session.login()

    describe 'given an existing board id', ->
      beforeEach (done) ->
        Factory "board", (err, board) ->
          id = board.id
          done()

      it 'returns the board page', (done) ->
        session.request()
          .get("/boards/#{id}")
          .end (req, res) ->
            expect(res.statusCode).toBe(200)
            done()

  describe '#destroy', ->
    board = undefined
    response = undefined

    beforeEach (done) ->
      session.login()

      Factory "board", (err, _board) ->
        board = _board
        session.request()
          .post("/boards/#{board.id}")
          .end (err, _response) ->
            response = _response
            done()

    it 'redirects to the root', ->
      expect(response.redirect).toBeTruthy()
      redirect = url.parse response.headers.location
      expect(redirect.pathname).toEqual '/'

    it 'deletes the board', (done) ->
      Board.findById board.id, (err, board) ->
        expect(board).toBeNull()
        done()

  describe '#build', ->
    name = 'name-1'
    creator = 'board-creator-1'

    beforeEach (done) ->
      boardsController = new BoardsController
      boardsController.build name, creator, (board) ->
        done()

    it 'creates a new board', (done) ->
      countBoards = (next) ->
        Board.count (err, count) ->
          expect(count).toEqual 1
          next(null)

      findFirstBoard = (next) ->
        Board.findOne {}, (err, board) ->
          next(null, board.id)

      findBoardById = (id, next) ->
        Board.findById id, (err, board) ->
          board = board.toObject getters: true
          next(null, board)

      assertOwnership = (board, next) ->
        expect(board.name).toEqual name
        expect(board.creator).toEqual creator
        expect(board.groups[0].cards.length).toEqual 1

        card = board.groups[0].cards[0]
        expect(card.creator).toEqual creator
        expect(card.authors[0]).toEqual '@carbonfive'
        expect(card.text).toContain 'Welcome to your virtual whiteboard!'
        next(null)

      async.waterfall [ countBoards, findFirstBoard, findBoardById, assertOwnership ], done
