{ mongoose, db } = require './db'
Populator = require "./populator"
Card = require "./card"

BoardSchema = new mongoose.Schema
  name: String
  creator: String
  created: Date
  updated: Date

BoardSchema.pre 'save', (next) ->
  @created = new Date() unless @created?
  @updated = new Date()
  next()

BoardSchema.statics =
  findById: (id, callback) ->
    @findOne { _id: id }, @populate(callback)

  createdBy: (user, callback) ->
    @find { creator: user }, null, { sort: 'name' }, @populate(callback)

  collaboratedBy: (user, callback) ->
    Card.find { authors: user }, (error, cards) =>
      boardIds = cards.map (card) ->
        card.boardId
      @find { _id: { $in: boardIds }, creator: { $ne: user } }, null, { sort: 'name' }, @populate(callback)

  populate: (callback) ->
    new Populator('board', 'card').populate callback

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

  destroy: (callback) ->
    @remove (error) =>
      if (error)
        callback(error)
      else
        Card.findByBoardId(@id).remove (error) ->
          callback(error)

  updateAttributes: (attributes, callback) ->
    for attribute in ['name'] when attributes[attribute]?
      @[attribute] = attributes[attribute]
    @save (error, card) ->
      callback error, card

Board = db.model 'Board', BoardSchema

module.exports = Board
