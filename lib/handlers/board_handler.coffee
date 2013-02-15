Handler = require './handler'
Board = require '../models/board'

class BoardHandler extends Handler

  constructor: ->
    super Board, 'board'

module.exports = BoardHandler
