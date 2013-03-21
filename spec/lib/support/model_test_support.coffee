lib = "#{__dirname}/../../../lib"
speclib = "#{__dirname}/.."

{ mongoose } = require "#{lib}/models/db"
Board = require "#{lib}/models/board"
Group = require "#{lib}/models/group"
Card = require "#{lib}/models/card"
User = require "#{lib}/models/user"
AuthUser = require "#{lib}/models/auth_user"

Factory = require "#{speclib}/support/factories"
async = require 'async'

timeout = null
finalizers = []

finalizers.push ->
  mongoose.disconnect()

afterAll = ->
  f() for f in finalizers

beforeEach (next)->
  clearTimeout timeout if timeout?
  Board.remove (err)->
    Group.remove (err)->
      Card.remove (err)->
        AuthUser.remove (err)->
          next()

afterEach ->
  timeout = setTimeout afterAll, 100

module.exports = { finalizers, Board, Group, Card, User, AuthUser, Factory, async }
