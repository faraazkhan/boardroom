request = require 'supertest'
jsdom = require 'jsdom'
url = require 'url'
$ = require 'jquery'
Factory = require './../support/factories'
Board = require "#{__dirname}/../../../lib/models/board"
Card = require "#{__dirname}/../../../lib/models/card"
LoggedInRouter = require './../support/authentication'

describe 'BoardsController', ->
  beforeEach (done) ->
    Board.remove (error) ->
      done error if error?
      Card.remove (error) ->
        done error if error?
        done()

  describe '#create', ->
    router = null
    count = null

    beforeEach (done) ->
      Board.count (error, currentCount) ->
        done error if error?
        router = new LoggedInRouter
        count = currentCount
        done()

    it 'creates a new board', (done) ->
      title = 'title-1'
      request(router.app)
        .post('/boards')
        .send(title: title)
        .end (error, response) ->
          done error if error?
          Board.count (error, count) ->
            done error if error
            expect(count).toEqual 1
            Board.findOne {}, (error, board) ->
              done error if error?
              expect(board.title).toEqual title
              expect(board.name).toEqual title
              expect(board.creator_id).toEqual '1'
              done()

  describe '#index', ->
    router = null
    boards = []

    beforeEach (done) ->
      Factory.create 'board', (board) ->
        boards.push board
        Factory.create 'card', boardId: board.id, ->
          Factory.create 'board', (board) ->
            boards.push board
            done()

      router = new LoggedInRouter

    it 'renders the boards page', (done) ->
      request(router.app)
        .get('/boards')
        .end (error, response) ->
          done error if error?
          jsdom.env
            html: response.text
            done: (error, window) ->
              doen(error) if error?
              expect(response.ok).toBeTruthy()
              expect($('#boards li', window.document).length).toEqual 2
              done()

  describe '#show', ->
    router = null
    board = null

    beforeEach (done) ->
      router = new LoggedInRouter
      Factory.create 'board', (defaultBoard) ->
        board = defaultBoard
        done()

    describe 'given a board', ->
      it 'returns the board page', (done) ->
        request(router.app)
          .get("/boards/#{board.id}")
          .end (error, response) ->
            done error if error?
            expect(response.statusCode).toBe(200)
            done()

    describe 'given no board', ->
      it 'returns a 404 code', (done) ->
        request(router.app)
          .get('/boards/unknownid')
          .end (error, response) ->
            done error if error?
            expect(response.statusCode).toBe(404)
            done()

  describe '#destroy', ->
    router = null
    board = null

    beforeEach (done) ->
      router = new LoggedInRouter
      Factory.create 'board', (defaultBoard) ->
        board = defaultBoard
        done()

    it 'deletes the board', (done) ->
      request(router.app)
        .post("/boards/#{board.id}")
        .end (error, response) ->
          done error if error?
          expect(response.redirect).toBeTruthy()
          redirect = url.parse response.headers.location
          expect(redirect.pathname).toEqual '/boards'
          Board.findById board.id, (error, board) ->
            done error if error?
            expect(board).toBeNull()
            done()

