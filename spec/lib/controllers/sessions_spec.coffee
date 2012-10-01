{ LoggedOutRouter, LoggedInRouter, request, url } =
  require '../support/controller_test_support'

describe 'SessionsController', ->
  router = null

  describe '#new', ->
    beforeEach ->
      router = new LoggedOutRouter

    it 'renders the login page', (done) ->
      request(router.app)
        .get('/login')
        .end (error, response) ->
          done error if error?
          expect(response.ok).toBeTruthy()
          done()

  describe '#create', ->
    beforeEach ->
      router = new LoggedOutRouter

    it 'redirects to the home page', (done) ->
      request(router.app)
        .post('/login')
        .end (error, response) ->
          done error if error?
          expect(response.redirect).toBeTruthy()
          redirect = url.parse response.headers.location
          expect(redirect.path).toEqual '/'
          done()

  describe '#destroy', ->
    beforeEach ->
      router = new LoggedInRouter

    it 'logs out', (done) ->
      request(router.app)
        .get('/logout')
        .end (error, response) ->
          done error if error?
          expect(response.redirect).toBeTruthy()
          redirect = url.parse response.headers.location
          expect(redirect.path).toEqual '/'
          done()

