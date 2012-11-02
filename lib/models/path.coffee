{ mongoose, db } = require './db'

PathSchema = new mongoose.Schema
  boardId: String
  creator: String
  data: Array
  created: Date
  updated: Date

PathSchema.pre 'save', (next) ->
  @created = new Date() unless @created?
  @updated = new Date()
  next()

PathSchema.statics =
  findByBoardId: (boardId, callback) ->
    @find { boardId: boardId }, callback

PathSchema.methods =
  updateAttributes: (attributes, callback) ->
    for attribute in ['data'] when attributes[attribute]?
      @[attribute] = attributes[attribute]
    if attributes.author?
      @authors.push attributes.author unless attributes.author in @authors
    @save (error, card) ->
      callback error, card

Path = db.model 'Path', PathSchema

module.exports = Path
