lib = "#{__dirname}/../../../lib"
speclib = "#{__dirname}/.."
require "#{speclib}/support/spec_helper"

{ mongoose } = require "#{lib}/models/db"
Board = require "#{lib}/models/board"
Group = require "#{lib}/models/group"
Card = require "#{lib}/models/card"
User = require "#{lib}/models/user"
AuthUser = require "#{lib}/models/auth_user"

Factory = require "#{speclib}/support/factories"

timeout = null
finalizers = []

finalizers.push ->
  mongoose.disconnect()

afterAll = ->
  f() for f in finalizers

beforeEach ->
  clearTimeout timeout if timeout?
  Board.sync.remove()
  Group.sync.remove()
  Card.sync.remove()
  AuthUser.sync.remove()

afterEach ->
  timeout = setTimeout afterAll, 100

module.exports = { finalizers, Board, Group, Card, User, AuthUser, Factory }
