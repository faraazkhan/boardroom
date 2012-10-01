{ Factory, Board, Card, LoggedInRouter, request, jsdom, url, $ } =
  require '../support/controller_test_support'

describe 'BoardsController', ->
  router = null

  describe '#create', ->
    beforeEach ->
      router = new LoggedInRouter

    it 'creates a new board', (done) ->
      name = 'name-1'
      request(router.app)
        .post('/boards')
        .send(name: name)
        .end (error, response) ->
          done error if error?
          Board.count (error, count) ->
            done error if error
            expect(count).toEqual 1
            Board.findOne {}, (error, board) ->
              done error if error?
              expect(board.name).toEqual name
              expect(board.creator).toEqual 'user'
              done()

  describe '#show', ->
    board = null
    beforeEach (done) ->
      router = new LoggedInRouter
      Factory.create 'board', (defaultBoard) ->
        board = defaultBoard
        done()

    describe 'given a board', ->
      it 'returns the board page', (done) ->
        request(router.app)
          .get("/boards/#{board.id}")
          .end (error, response) ->
            done error if error?
            expect(response.statusCode).toBe(200)
            done()

    describe 'given no board', ->
      it 'returns a 404 code', (done) ->
        request(router.app)
          .get('/boards/unknownid')
          .end (error, response) ->
            done error if error?
            expect(response.statusCode).toBe(404)
            done()

  describe '#destroy', ->
    board = null
    beforeEach (done) ->
      router = new LoggedInRouter
      Factory.create 'board', (defaultBoard) ->
        board = defaultBoard
        done()

    it 'deletes the board', (done) ->
      request(router.app)
        .post("/boards/#{board.id}")
        .end (error, response) ->
          done error if error?
          expect(response.redirect).toBeTruthy()
          redirect = url.parse response.headers.location
          expect(redirect.pathname).toEqual '/'
          Board.findById board.id, (error, board) ->
            done error if error?
            expect(board).toBeNull()
            done()
