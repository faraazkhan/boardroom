{ describeController, request } =
  require '../support/controller_test_support'

describeController 'UsersController', (session) ->
  describe '#avatar', ->
    it "redirects to the url for the handle's avatar", (done) =>
      session.request()
        .get("/user/avatar/#{encodeURIComponent '@handle'}")
        .end (request, response) ->
          expect(response.redirect).toBeTruthy()
          expect(response.headers.location).toMatch /api.twitter.com/
          done()
