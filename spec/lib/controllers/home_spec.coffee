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
        expect($('.board-list', response.text).length).toEqual 1
        expect($('.board-list ul.created li', response.text).length).toEqual 1
        expect($('.board-list ul.collaborated li', response.text).length).toEqual 2

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
