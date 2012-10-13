{ LoggedOutRouter, LoggedInRouter, request, url } =
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

    it 'redirects to the home page', ->
      response = request(@router.app)
        .post('/login')
        .sync
        .end()
      expect(response.redirect).toBeTruthy()
      redirect = url.parse response.headers.location
      expect(redirect.path).toEqual '/'

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
