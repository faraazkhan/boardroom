{ Factory, Board, Card, describeController, jsdom, url, $ } =
  require '../support/controller_test_support'

describeController 'HomeController', (session) ->
  describe '#index', ->
    describe 'when logged in', ->
      beforeEach (done) ->
        Factory.createBundle (err, bundle) ->
          session.login bundle.users.boardCreator1
          done()

      it 'shows my boards', (done) ->
        session.request()
          .get('/')
          .end (req, res) ->
            expect(res.ok).toBeTruthy()
            expect($('.board-list', res.text).length).toEqual 1
            expect($('.board-list ul.created li', res.text).length).toEqual 1
            expect($('.board-list ul.collaborated li', res.text).length).toEqual 3
            done()

    describe 'when logged out', ->
      it 'redirects to the login page', (done) ->
        session.request()
          .get('/')
          .end (req, res) ->
            expect(res.redirects).toBeTruthy()
            redirect = url.parse res.headers.location
            expect(redirect.pathname).toEqual '/login'
            done()
