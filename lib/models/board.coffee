{ mongoose, db } = require './db'
Card = require "#{__dirname}/card"

BoardSchema = new mongoose.Schema
  name: String
  creator: String
  groups: Array
  created: Date
  updated: Date

BoardSchema.pre 'save', (next) ->
  @created = new Date() unless @created?
  @updated = new Date()
  next()

BoardSchema.statics =
  findById: (id, callback) ->
    @findOne { _id: id }, @_decorate(callback)

  createdBy: (user, callback) ->
    @find { creator: user }, null, { sort: 'name' }, @_decorate(callback)

  collaboratedBy: (user, callback) ->
    Card.find { authors: user }, (error, cards) =>
      boardIds = cards.map (card) ->
        card.boardId
      @find { _id: { $in: boardIds }, creator: { $ne: user } }, null, { sort: 'name' }, @_decorate(callback)

  _decorate: (callback) ->
    return undefined unless callback?
    (error, boards) ->
      return callback error, boards unless boards?
      if boards.length?
        boardMap = {}
        boardMap[board.id] = board for board in boards
        boardIds = ( board.id for board in boards )
        board.cards = [] for board in boards
        Card.find { boardId: { $in: boardIds } }, (error, cards) ->
          boardMap[card.boardId].cards.push card for card in cards
          callback error, boards
      else
        board = boards
        Card.find { boardId: board.id }, (error, cards) ->
          board.cards = cards
          callback error, board

BoardSchema.methods =
  collaborators: ->
    collabs = []
    ( ( collabs.push user unless ( user == @creator or collabs.indexOf(user) >= 0 ) ) \
      for user in card.authors ) for card in @cards
    collabs

  lastUpdated: ->
    up = @updated
    ( up = if up.getTime() > card.updated.getTime() then up else card.updated ) for card in @cards
    up

  addGroup: (attributes, callback) ->
    @_id = null
    @groups.push attributes
    @save (error) ->
      callback attributes

  destroy: (callback) ->
    @remove (error) =>
      if (error)
        callback(error)
      else
        Card.findByBoardId(@id).remove (error) ->
          callback(error)

Board = db.model 'Board', BoardSchema

module.exports = Board
