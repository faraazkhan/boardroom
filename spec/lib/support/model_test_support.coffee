lib = "#{__dirname}/../../../lib"
speclib = "#{__dirname}/.."
require "#{speclib}/support/spec_helper"

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

beforeEach ->
  clearTimeout timeout if timeout?
  Board.sync.remove()
  Card.sync.remove()

afterEach ->
  timeout = setTimeout afterAll, 100

module.exports = { finalizers, Board, Card, User, Factory }
