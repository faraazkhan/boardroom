{ mongoose, db } = require './db'

BoardSchema = new mongoose.Schema
  name: String
  title: String
  creator_id: String
  deleted: Boolean
  groups: Array

BoardSchema.statics =
  findBoards: (callback) ->
    @where('deleted', false)
      .exec (error, boards) ->
        callback(boards)

  findByName: (name, callback) ->
    @findOne name: name, (error, attributes) ->
      callback new Board(attributes)

  findOrCreateByNameAndCreatorId: (name, creator_id, callback) ->
    @findOne { name, creator_id }, (error, attributes) ->
      if board?
        callback board
      else
        board = new Board { name, creator_id }
        board.save (error) ->
          callback board

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

module.exports = { Board }
