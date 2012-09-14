request = require 'supertest'
jsdom = require 'jsdom'
$ = require 'jquery'
Factory = require './../support/factories'
Board = require "#{__dirname}/../../../app/server/models/board"
Card = require "#{__dirname}/../../../app/server/models/card"
LoggedInRouter = require './../support/authentication'

describe 'BoardsController', ->
  describe '#create', ->
    router = null
    count = null

    beforeEach (done) ->
      Board.remove ->
        Board.count (error, currentCount) ->
          done(error) if error
          router = new LoggedInRouter
          count = currentCount
          done()

    it 'creates a new board', (done) ->
      title = 'title-1'
      request(router.app)
        .post('/boards')
        .send(title: title)
        .end (error, response) ->
          throw error if error
          Board.count (error, count) ->
            done(error) if error
            expect(count).toEqual 1
            Board.findOne {}, (error, board) ->
              done(error) if error
              expect(board.title).toEqual title
              expect(board.name).toEqual title
              expect(board.creator_id).toEqual '1'
              done()

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
