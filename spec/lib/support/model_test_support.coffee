lib = "#{__dirname}/../../../lib"
speclib = "#{__dirname}/.."

{ db } = require "#{lib}/models/db"
Board = require "#{lib}/models/board"
Card = require "#{lib}/models/card"
User = require "#{lib}/models/user"

Factory = require "#{speclib}/support/factories"

timeout = null
finalizers = []

finalizers.push ->
  db.close()

afterAll = ->
  f() for f in finalizers

beforeEach (done) ->
  clearTimeout timeout if timeout?
  Board.remove ->
    Card.remove done

afterEach ->
  timeout = setTimeout afterAll, 100

module.exports = { finalizers, Board, Card, User, Factory }
