{ mongoose } = require './db'
Card = require './card'

GroupSchema = new mongoose.Schema
  boardId : { type: String, required: true }
  name    : { type: String, default: '' }
  x       : { type: Number, required: true }
  y       : { type: Number, required: true }
  z       : { type: Number, default: 0 }
  created : { type: Date }
  updated : { type: Date }

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

  collaboratedBy: (username, callback) ->
    Card.find { authors: username }, (error, cards) =>
      groupIds = ( card.groupId for card in cards when card.groupId? )
      @find { _id: { $in: groupIds } }, null, { sort: 'name' }, callback

GroupSchema.methods =
  updateAttributes: (attributes, callback) ->
    for attribute in ['name', 'x', 'y', 'z'] when attributes[attribute]?
      @[attribute] = attributes[attribute]
    @save (error, card) ->
      callback error, card

  isRemovable: (callback) ->
    Card.findByGroupId @id, (error, cards) ->
      callback(cards.length == 0)


Group = mongoose.model 'Group', GroupSchema

module.exports = Group
