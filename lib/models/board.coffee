{ mongoose, db } = require './db'
Card = require "#{__dirname}/card"

BoardSchema = new mongoose.Schema
  name: String
  title: String
  creator_id: String
  deleted: Boolean
  groups: Array

BoardSchema.statics =
  all: (callback) ->
    @find()
      .or([{ deleted: false }, { deleted: { $exists: false } }])
      .exec (error, boards) ->
        callback boards

BoardSchema.methods =
  addGroup: (attributes, callback) ->
    @_id = null
    @groups.push attributes
    @save (error) ->
      callback attributes

  destroy: (callback) ->
    @remove (error) =>
      if (error)
        callback(error)
      else
        Card.findByBoardId(@id).remove (error) ->
          callback(error)

Board = db.model 'Board', BoardSchema

module.exports = Board
