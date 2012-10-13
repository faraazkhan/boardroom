{ Factory, Board, Card, LoggedOutRouter, LoggedInRouter, request, jsdom, url, $ } =
  require '../support/controller_test_support'

describe 'HomeController', ->
  describe '#index', ->
    describe 'when logged in', ->
      beforeEach ->
        @router = new LoggedInRouter 'board-creator-1'
        Factory.sync.createBundle()

      it 'shows my boards', ->
        response = request(@router.app)
          .get('/')
          .sync
          .end()
        expect(response.ok).toBeTruthy()
        window = jsdom.sync.env response.text
        expect($('#boards ul', window.document).length).toEqual 2
        expect($('#boards ul.created li', window.document).length).toEqual 1
        expect($('#boards ul.collaborated li', window.document).length).toEqual 2

    describe 'when logged out', ->
      beforeEach ->
        @router = new LoggedOutRouter

      it 'redirects to the login page', ->
        response = request(@router.app)
          .get('/')
          .sync
          .end()
        expect(response.redirects).toBeTruthy()
        redirect = url.parse response.headers.location
        expect(redirect.pathname).toEqual '/login'
