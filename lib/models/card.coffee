{ mongoose, db } = require './db'

CardSchema = new mongoose.Schema
  boardId: String
  creator: String
  authors: Array
  plusAuthors: Array
  x: Number
  y: Number
  z: Number
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
    for attribute in ['x', 'y', 'z', 'text', 'colorIndex', 'deleted'] when attributes[attribute]?
      @[attribute] = attributes[attribute]
    if attributes.author?
      @authors.push attributes.author unless attributes.author in @authors
    if attributes.plusAuthor?
      @plusAuthors.push attributes.plusAuthor unless attributes.plusAuthor in @plusAuthors
    @save (error, card) ->
      callback error, card

Card = db.model 'Card', CardSchema

module.exports = Card
