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

BoardSchema.pre 'init', (next) ->
  Card.find { boardId: @id }, (error, cards) =>
    @cards = cards
    next()

BoardSchema.statics =
  created_by: (user, callback) ->
    @find { creator: user }, null, { sort: 'name' }, @_decorate(callback)

  collaborated_by: (user, callback) ->
    Card.find { authors: user }, (error, cards) =>
      boardIds = cards.map (card) ->
        card.boardId
      @find { _id: { $in: boardIds }, creator: { $ne: user } }, null, { sort: 'name' }, @_decorate(callback)

  _decorate: (callback) ->
    return undefined unless callback?
    (error, boards) ->
      boardIds = ( board.id for board in boards )
      boardMap = {}
      boardMap[board.id] = board for board in boards
      Card.find { boardId: { $in: boardIds } }, (error, cards) ->
        boardMap[card.boardId].cards.push card for card in cards
        callback error, boards

BoardSchema.methods =
  collaborators: ->
    collabs = []
    ( ( collabs.push user unless ( user == @creator or collabs.indexOf(user) >= 0 ) ) \
      for user in card.authors ) for card in @cards
    collabs

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
