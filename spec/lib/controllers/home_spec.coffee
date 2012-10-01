{ Factory, Board, Card, LoggedOutRouter, LoggedInRouter, request, jsdom, url, $ } =
  require '../support/controller_test_support'

describe 'HomeController', ->
  router = null

  describe '#index', ->
    describe 'when logged in', ->
      beforeEach (done) ->
        router = new LoggedInRouter 'board-creator-1'
        Factory.createBundle 'typical', ->
          done()

      it 'shows my boards', (done) ->
        request(router.app)
          .get('/')
          .end (error, response) ->
            done error if error?
            jsdom.env
              html: response.text
              done: (error, window) ->
                done(error) if error?
                expect(response.ok).toBeTruthy()
                expect($('#boards ul', window.document).length).toEqual 2
                expect($('#boards ul.created li', window.document).length).toEqual 1
                expect($('#boards ul.collaborated li', window.document).length).toEqual 2
                done()

    describe 'when logged out', ->
      beforeEach ->
        router = new LoggedOutRouter

      it 'redirects to the login page', (done) ->
        request(router.app)
          .get('/')
          .end (error, response) ->
            done error if error?
            expect(response.redirects).toBeTruthy()
            redirect = url.parse response.headers.location
            expect(redirect.pathname).toEqual '/login'
            done()
