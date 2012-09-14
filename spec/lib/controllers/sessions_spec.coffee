request = require 'supertest'
url = require 'url'
Router = require "#{__dirname}/../../../lib/routes"
LoggedInRouter = require './../support/authentication'

describe 'SessionsController', ->
  describe '#new', ->
    router = null

    beforeEach ->
      router = new Router

    it 'renders the login page', (done) ->
      request(router.app)
        .get('/login')
        .end (error, response) ->
          expect(response.ok).toBeTruthy()
          done()

  describe '#create', ->
    router = null

    beforeEach ->
      router = new Router

    it 'redirects to the home page', (done) ->
      request(router.app)
        .post('/login')
        .end (error, response) ->
          expect(response.redirect).toBeTruthy()
          redirect = url.parse response.headers.location
          expect(redirect.path).toEqual '/'
          done()

  describe '#destroy', ->
    router = null

    beforeEach ->
      router = new LoggedInRouter

    it 'logs out', (done) ->
      request(router.app)
        .get('/logout')
        .end (error, response) ->
          expect(response.redirect).toBeTruthy()
          redirect = url.parse response.headers.location
          expect(redirect.path).toEqual '/'
          done()

