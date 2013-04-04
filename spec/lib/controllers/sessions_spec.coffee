{ LoggedOutRouter, LoggedInRouter, Board, Factory, request, superagent, url, async } =
  require '../support/controller_test_support'

describe 'SessionsController', ->
  describe '#new', ->
    beforeEach =>
      @router = new LoggedOutRouter

    it 'renders the login page', (done) =>
      request(@router.app)
        .get('/login')
        .end (req, res) ->
          expect(res.ok).toBeTruthy()
          done()

  describe '#create', ->
    beforeEach =>
      @router = new LoggedOutRouter

    describe 'given the user has existing boards', =>
      beforeEach (done) =>
        Factory.createBundle done

      it 'redirects to the home page', (done) =>
        request(@router.app)
          .post('/login')
          .send({user_id: 'board-creator-1'})
          .end (request, response) ->
            expect(response.redirect).toBeTruthy()
            redirect = url.parse response.headers.location
            expect(redirect.path).toEqual '/'
            done()

    describe 'given the user has no boards', =>
      it 'creates a default board and redirects to its page', (done) =>
        request(@router.app)
          .post('/login')
          .send({user_id: 'board-creator-1'})
          .end (request, response) ->
            console.log response.redirect
            expect(response.redirect).toBeTruthy()

            Board.count (err, count) ->
              expect(count).toEqual 1

              Board.findOne { creator: 'board-creator-1' }, (err, board) ->
                redirect = url.parse response.headers.location
                expect(redirect.path).toEqual "/boards/#{board.id}"
                expect(board.name).toEqual "board-creator-1's board"
                done()

    describe 'given the user is trying to go to an existing board', =>
      beforeEach =>
        @agent = superagent.agent()

      it 'brings the user to that board', (done) =>
        async.series [
          (done) =>
            request(@router.app)
              .get('/boards/123')
              .end (request, response) =>
                @agent.saveCookies response
                done()
          , (done) =>
            req = request(@router.app)
              .post('/login')
            @agent.attachCookies req
            req
              .send({user_id: 'board-creator-1'})
              .end (request, response) ->
                expect(response.redirect).toBeTruthy()
                redirect = url.parse response.headers.location
                expect(redirect.path).toEqual '/boards/123'
                done()
          ], done

  describe '#destroy', ->
    beforeEach =>
      @router = new LoggedInRouter

    it 'logs out', (done) =>
      request(@router.app)
        .get('/logout')
        .end (request, response) ->
          expect(response.redirect).toBeTruthy()
          redirect = url.parse response.headers.location
          expect(redirect.path).toEqual '/'
          done()
