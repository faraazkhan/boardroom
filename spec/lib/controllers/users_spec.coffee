{ LoggedOutRouter, request } =
  require '../support/controller_test_support'

describe 'UsersController', ->
  describe '#avatar', ->
    beforeEach ->
      @router = new LoggedOutRouter

    it "redirects to the url for the handle's avatar", ->
      response = request(@router.app)
        .get("/user/avatar/#{encodeURIComponent '@handle'}")
        .sync
        .end()
      expect(response.redirect).toBeTruthy()
      expect(response.headers.location).toMatch /api.twitter.com/
