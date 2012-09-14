{ mongoose, db } = require './db'

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

  findByName: (name, callback) ->
    @findOne name: name, (error, board) ->
      if board?
        callback undefined, board
      else
        callback message: 'board not found'

BoardSchema.methods =
  addGroup: (attributes, callback) ->
    @_id = null
    @groups.push attributes
    @save (error) ->
      callback attributes

  destroy: (callback) ->
    @deleted = true
    @save (error) ->
      callback()

Board = db.model 'Board', BoardSchema

module.exports = Board
