{ Factory, Board, Card, LoggedOutRouter, LoggedInRouter, request, jsdom, url, $ } =
  require '../support/controller_test_support'

describe 'HomeController', ->
  describe '#index', ->
    describe 'when logged in', ->
      beforeEach (done) =>
        @router = new LoggedInRouter 'board-creator-1'
        Factory.createBundle done

      it 'shows my boards', (done) =>
        request(@router.app)
          .get('/')
          .end (req, res) ->
            expect(res.ok).toBeTruthy()
            expect($('.board-list', res.text).length).toEqual 1
            expect($('.board-list ul.created li', res.text).length).toEqual 1
            expect($('.board-list ul.collaborated li', res.text).length).toEqual 2
            done()

    describe 'when logged out', ->
      beforeEach =>
        @router = new LoggedOutRouter

      it 'redirects to the login page', (done) =>
        request(@router.app)
          .get('/')
          .end (req, res) ->
            expect(res.redirects).toBeTruthy()
            redirect = url.parse res.headers.location
            expect(redirect.pathname).toEqual '/login'
            done()
