request = require 'supertest'
url = require 'url'
Router = require "#{__dirname}/../../../app/server/routes"
LoggedInRouter = require './../support/authentication'

describe 'HomeController', ->
  describe '#index', ->
    describe 'when logged in', ->
      router = null

      beforeEach ->
        router = new LoggedInRouter

      it 'redirects to the boards index', (done) ->
        request(router.app)
          .get('/')
          .end (error, response) ->
            expect(response.redirect).toBeTruthy()
            redirect = url.parse response.headers.location
            expect(redirect.pathname).toEqual '/boards'
            done()

    describe 'when logged out', ->
      router = null

      beforeEach ->
        router = new Router

      it 'redirects to the login page', (done) ->
        request(router.app)
          .get('/')
          .end (error, response) ->
            expect(response.redirects).toBeTruthy()
            redirect = url.parse response.headers.location
            expect(redirect.pathname).toEqual '/login'
            done()
