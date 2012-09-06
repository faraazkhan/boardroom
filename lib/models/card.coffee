mongoose = require 'mongoose'

connection = mongoose.createConnection 'localhost',
  "boardroom_#{process.env['NODE_ENV'] || 'development'}"

CardSchema = new mongoose.Schema
  boardName: String
  author: String
  x: Number
  y: Number
  text: String
  deleted: Boolean
  authors: Array

CardSchema.statics.countsByBoard = (callback) ->
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

CardSchema.statics.findByBoardName = (boardName, callback) ->
  @where('boardName', boardName)
    .exec (error, cards) ->
      callback cards

CardSchema.methods.updateAttributes = (attributes, callback) ->
  for attribute in ['x', 'y', 'text', 'colorIndex', 'deleted']
    @[attribute] = attributes[attribute] if attributes[attribute]?
  if @author? &&
    (attributes.authors? &&
     ! (attributes.authors.indexOf(@author) > -1))
    (attributes.authors ||= []).push(@author)
  @save (error) ->
    callback

Card = connection.model 'Card', CardSchema

module.exports = { Card }
