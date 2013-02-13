Handler = require './handler'
Board = require '../models/board'
Group = require '../models/group'
Card = require '../models/card'

class BoardHandler extends Handler

  constructor: ->
    super Board, 'board'

module.exports = BoardHandler
