request = require 'supertest'
jsdom = require 'jsdom'
$ = require 'jquery'
{ Factory } = require './../support/factories'
{ Board } = require "#{__dirname}/../../../app/server/models/board"
{ Card } = require "#{__dirname}/../../../app/server/models/card"
{ LoggedInRouter } = require './../support/authentication'

describe 'BoardsController', ->
  describe '#index', ->
    router = null
    boards = []

    beforeEach (done) ->
      Board.remove ->
        Card.remove ->
          Factory.create 'board', (board) ->
            boards.push board
            Factory.create 'card', boardName: board.name, ->
              Factory.create 'board', (board) ->
                boards.push board
                done()

      router = new LoggedInRouter

    it 'renders the boards page', (done) ->
      request(router.app)
        .get('/boards')
        .end (error, response) ->
          jsdom.env
            html: response.text
            done: (error, window) ->
              expect(response.ok).toBeTruthy()
              expect($('#boards li', window.document).length).toEqual 2
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
    board = null

    beforeEach (done) ->
      Board.remove ->
        Card.remove ->
          Factory.create 'board', (defaultBoarc) ->
            board = defaultBoarc
            Factory.create 'card', boardName: board.name, ->
              done()

      router = new LoggedInRouter

    it 'returns board data as json', (done) ->
      request(router.app)
        .get("/boards/#{board.name}/info")
        .end (error, response) ->
          expect(response.ok).toBeTruthy()

          body = response.body
          expect(body.name).toEqual board.name
          expect(body.cards.length).toEqual 1
          expect(body.groups).toEqual []
          expect(body.users).toEqual {}
          expect(body.title).toEqual board.name
          expect(body.user_id).toEqual 1
          done()
