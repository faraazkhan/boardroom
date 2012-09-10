request = require 'supertest'
{ LoggedInRouter } = require './../support/authentication'

describe 'BoardsController', ->
  describe '#index', ->
    router = null

    beforeEach ->
      router = new LoggedInRouter

    it 'renders the boards page', (done) ->
      request(router.app)
        .get('/boards')
        .end (error, response) ->
          expect(response.ok).toBeTruthy()
          done()

  describe '#show', ->
    router = null

    beforeEach ->
      router = new LoggedInRouter

    it 'renders the board page', (done) ->
      request(router.app)
        .get('/boards/1')
        .end (error, response) ->
          expect(response.ok).toBeTruthy()
          done()

  describe '#info', ->
    router = null

    beforeEach ->
      router = new LoggedInRouter

    it 'returns board data as json', (done) ->
      request(router.app)
        .get('/boards/1/info')
        .end (error, response) ->
          expect(response.ok).toBeTruthy()

          body = response.body
          expect(body.name).toEqual '1'
          expect(body.cards).toEqual []
          expect(body.groups).toEqual []
          expect(body.users).toEqual {}
          expect(body.title).toEqual '1'
          expect(body.user_id).toEqual 1
          done()
