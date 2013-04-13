{ mongoose } = require './db'

CardSchema = new mongoose.Schema
  groupId      : { type: String, required: true }
  _creator     : { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
  creator      : { type: String }
  _authors     : [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }]
  authors      : { type: Array, default: [] }
  _plusAuthors : [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }]
  plusAuthors  : { type: Array, default: [] }
  text         : { type: String, default: '' }
  colorIndex   : { type: Number, default: 2, min: 0, max: 4 }
  created      : { type: Date }
  updated      : { type: Date }

CardSchema.pre 'save', (next) ->
  @created = new Date() unless @created?
  @updated = new Date()
  next()

CardSchema.statics =
  findByGroupId: (groupId, callback) ->
    @find { groupId }, callback

CardSchema.methods =
  updateAttributes: (attributes, callback) ->
    for attribute in ['text', 'colorIndex', 'groupId', 'plusAuthors', 'authors', '_plusAuthors', '_authors'] when attributes[attribute]?
      @[attribute] = attributes[attribute]
    @save (error, card) ->
      callback error, card

  isRemovable: (callback) ->
    callback true

Card = mongoose.model 'Card', CardSchema

module.exports = Card
