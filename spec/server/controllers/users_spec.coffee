request = require 'supertest'
{ Router } = require "#{__dirname}/../../../app/server/routes"

describe 'UsersController', ->
  describe '#avatar', ->
    describe 'given a Twitter handle', ->
      router = null

      beforeEach ->
        router = new Router

      it "redirects to the Twitter API for the handle's avatar", (done) ->
        request(router.app)
          .get("/user/avatar/#{encodeURIComponent '@handle'}")
          .end (error, response) ->
            expect(response.redirect).toBeTruthy()
            expect(response.headers.location).toMatch /api.twitter.com/
            done()

    describe 'given a non-Twitter handle', ->
      router = null

      beforeEach ->
        router = new Router

      it "redirects to the Gravatar for the handle", (done) ->
        request(router.app)
          .get('/user/avatar/handle')
          .end (error, response) ->
            expect(response.redirect).toBeTruthy()
            expect(response.headers.location).toMatch /www.gravatar.com/
            done()
