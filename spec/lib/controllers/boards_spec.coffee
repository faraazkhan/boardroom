{ Factory, Board, request, jsdom, url, $, async, describeController } =
  require '../support/controller_test_support'

BoardsController = require '../../../lib/controllers/boards'

describeController 'BoardsController', (session) ->
  describe '#create', ->
    name = 'name-1'
    response = undefined

    beforeEach (done) ->
      Factory.create 'user', (error, user) ->
        session.login user

        session.request()
          .post('/boards')
          .send({ name })
          .end (req, res)->
            response = res
            done()

    it 'creates a default board for the current user', (done)->
      Board.count {}, (err, count) ->
        expect(count).toEqual 1
        done()

    # it 'redirects to the new board', (done)->
    #   expect(response).toBeDefined()
    #   expect(response.redirect).toBeTruthy()
    #   Board.findOne { _creator: session.user.id }, (err, board) ->
    #     expect(board.name).toEqual name
    #     redirect = url.parse response.headers.location
    #     expect(redirect.path).toEqual "/boards/#{board.id}"
    #     done()

  # describe '#show', ->
  #   id = undefined

  #   beforeEach (done) ->
  #     Factory.create 'user', (error, user) ->
  #       session.login user
  #       done()

  #   describe 'given an existing board id', ->
  #     beforeEach (done) ->
  #       Factory "board", (err, board) ->
  #         id = board.id
  #         done()

  #     it 'returns the board page', (done) ->
  #       session.request()
  #         .get("/boards/#{id}")
  #         .end (req, res) ->
  #           expect(res.statusCode).toBe(200)
  #           done()

  # describe '#destroy', ->
  #   board = undefined
  #   response = undefined

  #   beforeEach (done) ->
  #     Factory.create 'user', (error, user) ->
  #       session.login user

  #       Factory "board", (err, _board) ->
  #         board = _board
  #         session.request()
  #           .post("/boards/#{board.id}")
  #           .end (err, _response) ->
  #             response = _response
  #             done()

  #   it 'redirects to the root', ->
  #     expect(response.redirect).toBeTruthy()
  #     redirect = url.parse response.headers.location
  #     expect(redirect.pathname).toEqual '/'

  #   it 'deletes the board', (done) ->
  #     Board.findById board.id, (err, board) ->
  #       expect(board).toBeNull()
  #       done()

  # describe '#build', ->
  #   name = 'name-1'
  #   creator = undefined

  #   beforeEach (done) ->
  #     Factory.create 'user', (error, user) ->
  #       creator = user.id
  #       boardsController = new BoardsController
  #       boardsController.build name, creator, (board) ->
  #         done()

  #   it 'creates a new board', (done) ->
  #     Board.find Board.populateMany (err, boards) ->
  #       expect(boards.length).toEqual 1
  #       board = boards[0].toObject getters: true
  #       expect(board.name).toEqual name
  #       expect(board._creator).toEqual creator._id
  #       expect(board.groups[0].cards.length).toEqual 1
  #       card = board.groups[0].cards[0]
  #       expect(card._creator).toEqual creator._id
  #       expect(card._authors[0]).toEqual creator._id
  #       expect(card.text).toContain 'Welcome to your virtual whiteboard!'
  #       done()
