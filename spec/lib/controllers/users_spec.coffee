request = require 'supertest'
Router = require "#{__dirname}/../../../lib/router"

describe 'UsersController', ->
  describe '#avatar', ->
    router = null

    beforeEach ->
      router = new Router

    it "redirects to the url for the handle's avatar", (done) ->
      request(router.app)
        .get("/user/avatar/#{encodeURIComponent '@handle'}")
        .end (error, response) ->
          done error if error?
          expect(response.redirect).toBeTruthy()
          expect(response.headers.location).toMatch /api.twitter.com/
          done()
