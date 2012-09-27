{ mongoose, db } = require './db'

CardSchema = new mongoose.Schema
  boardId: String
  creator: String
  x: Number
  y: Number
  text: String
  colorIndex: Number
  deleted: Boolean
  authors: Array
  focus: Boolean

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
      callback card

Card = db.model 'Card', CardSchema

module.exports = Card
