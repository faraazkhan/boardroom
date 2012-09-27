{ mongoose, db } = require './db'
Card = require "#{__dirname}/card"

BoardSchema = new mongoose.Schema
  name: String
  creator: String
  groups: Array

BoardSchema.statics =
  created_by: (user, callback) ->
    callback = @_decorate callback if callback?
    @find { creator: user }, null, { sort: 'name' }, callback

  collaborated_by: (user, callback) ->
    callback = @_decorate callback if callback?
    Card.find { authors: user }, (error, cards) =>
      boardIds = cards.map (card) ->
        card.boardId
      @find { _id: { $in: boardIds }, creator: { $ne: user } }, null, { sort: 'name' }, callback

  _decorate: (callback) ->
    (error, boards) ->
      boardMap = {}
      boardIds = []
      for board in boards
        do (board) ->
          board.cards = []
          boardIds.push board.id
          boardMap[board.id] = board
      Card.find { boardId: { $in: boardIds } }, (error, cards) ->
        for card in cards
          do (card) ->
            boardMap[card.boardId].cards.push card
        callback error, boards

BoardSchema.methods =
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
