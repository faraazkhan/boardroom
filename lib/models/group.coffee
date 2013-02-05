{ mongoose } = require './db'
Card = require './card'

GroupSchema = new mongoose.Schema
  boardId: String
  name: String
  x: Number
  y: Number
  z: Number
  created: Date
  updated: Date

GroupSchema.virtual('cards').set (cards) ->
  @vCards = cards

GroupSchema.virtual('cards').get () ->
  @vCards

GroupSchema.pre 'save', (next) ->
  @created = new Date() unless @created?
  @updated = new Date()
  next()

GroupSchema.pre 'remove', (next) ->
  Card.findByGroupId(@id).remove next

GroupSchema.statics =
  findByBoardId: (boardId, callback) ->
    @find { boardId }, callback

  collaboratedBy: (user, callback) ->
    Card.find { authors: user }, (error, cards) =>
      groupIds = ( card.groupId for card in cards )
      @find { _id: { $in: groupIds } }, null, { sort: 'name' }, callback

GroupSchema.methods =
  updateAttributes: (attributes, callback) ->
    for attribute in ['name', 'x', 'y', 'z'] when attributes[attribute]?
      @[attribute] = attributes[attribute]
    @save (error, card) ->
      callback error, card

  addCard: (newCard, callback)->
    newCard.groupId = @id
    newCard.save callback

  isRemovable: (callback) ->
    Card.findByGroupId @id, (error, cards) ->
      callback(cards.length == 0)


Group = mongoose.model 'Group', GroupSchema

module.exports = Group
