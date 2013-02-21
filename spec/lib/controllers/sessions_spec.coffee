{ LoggedOutRouter, LoggedInRouter, Board, Factory, request, url } =
  require '../support/controller_test_support'

describe 'SessionsController', ->
  describe '#new', ->
    beforeEach ->
      @router = new LoggedOutRouter

    it 'renders the login page', ->
      response = request(@router.app)
        .get('/login')
        .sync
        .end()
      expect(response.ok).toBeTruthy()

  describe '#create', ->
    beforeEach ->
      @router = new LoggedOutRouter

    describe 'given the user has existing boards', ->
      beforeEach ->
        Factory.sync.createBundle()

      it 'redirects to the home page', ->
        response = request(@router.app)
          .post('/login')
          .send({user_id: 'board-creator-1'})
          .sync
          .end()
        expect(response.redirect).toBeTruthy()
        redirect = url.parse response.headers.location
        expect(redirect.path).toEqual '/'

    describe 'given the user has no boards', ->
      it 'creates a default board and redirects to its page', ->
        response = request(@router.app)
          .post('/login')
          .send({user_id: 'board-creator-1'})
          .sync
          .end()

        expect(response.redirect).toBeTruthy()

        boardCount = Board.sync.count()
        expect(boardCount).toEqual 1

        board = Board.sync.findOne { creator: 'board-creator-1' }
        redirect = url.parse response.headers.location
        expect(redirect.path).toEqual "/boards/#{board.id}"
        expect(board.name).toEqual "board-creator-1's board"

  describe '#destroy', ->
    beforeEach ->
      @router = new LoggedInRouter

    it 'logs out', ->
      response = request(@router.app)
        .get('/logout')
        .sync
        .end()
      expect(response.redirect).toBeTruthy()
      redirect = url.parse response.headers.location
      expect(redirect.path).toEqual '/'
