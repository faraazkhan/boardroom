{ mongoose, db } = require './db'

CardSchema = new mongoose.Schema
  boardId: String
  creator: String
  authors: Array
  x: Number
  y: Number
  text: String
  colorIndex: Number
  deleted: Boolean
  focus: Boolean
  created: Date
  updated: Date

CardSchema.pre 'save', (next) ->
  @created = new Date() unless @created?
  @updated = new Date()
  next()

CardSchema.statics =
  findByBoardId: (boardId, callback) ->
    @find { boardId: boardId }, callback

CardSchema.methods =
  updateAttributes: (attributes, callback) ->
    for attribute in ['x', 'y', 'text', 'colorIndex', 'deleted'] when attributes[attribute]?
      @[attribute] = attributes[attribute]
    if attributes.author?
      @authors.push attributes.author unless author in @authors
    if attributes.authors?
      for author in attributes.authors
        @authors.push author unless author in @authors
    @save (error, card) ->
      callback error, card

Card = db.model 'Card', CardSchema

module.exports = Card
