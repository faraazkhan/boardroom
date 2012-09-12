{ mongoose, db } = require './db'

CardSchema = new mongoose.Schema
  boardName: String
  author: String
  x: Number
  y: Number
  text: String
  deleted: Boolean
  authors: Array
  focus: Boolean

CardSchema.statics =
  findByBoardName: (boardName, callback) ->
    @where('boardName', boardName)
      .exec (error, cards) ->
        callback cards

  countsByBoard: (callback) ->
    group =
      $group:
        _id: '$boardName'
        count:
          $sum: 1
    project =
      $project:
        boardName: 1
        count: 1
    @aggregate project, group, (error, response) =>
      fn = (totals, total) ->
        totals[total._id] = total.count
        totals
      results = response.reduce fn, {}
      callback results

CardSchema.methods =
  updateAttributes: (attributes, callback) ->
    for attribute in ['x', 'y', 'text', 'colorIndex', 'deleted']
      @[attribute] = attributes[attribute] if attributes[attribute]?
    if attributes.authors?
      for author in attributes.authors
        @authors.push author if author not in @authors
    @save (error) ->
      callback()

Card = db.model 'Card', CardSchema

module.exports = { Card }
