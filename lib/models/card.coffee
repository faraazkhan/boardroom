{ mongoose, db } = require './db'

CardSchema = new mongoose.Schema
  boardId: String
  author: String
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

  countsByBoard: (callback) ->
    group =
      $group:
        _id: '$boardId'
        count:
          $sum: 1
    project =
      $project:
        boardId: 1
        count: 1
    @aggregate project, group, (error, response) =>
      fn = (totals, total) ->
        totals[total._id] = total.count
        totals
      results = response.reduce fn, {}
      callback results

CardSchema.methods =
  updateAttributes: (attributes, callback) ->
    for attribute in ['x', 'y', 'text', 'colorIndex', 'deleted'] when attributes[attribute]?
      @[attribute] = attributes[attribute]
    if attributes.authors?
      for author in attributes.authors
        @authors.push author if author not in @authors
    @save (error, card) ->
      callback card

Card = db.model 'Card', CardSchema

module.exports = Card
