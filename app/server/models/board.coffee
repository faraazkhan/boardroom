mongoose = require 'mongoose'

connection = mongoose.createConnection 'localhost',
  "boardroom_#{process.env['NODE_ENV'] || 'development'}"

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

  findBoardAllowEmpty: (boardName, callback) ->
    @where('name', boardName)
      .findOne (error, board) ->
        callback(board)

  findOrCreateByNameAndCreatorId: (name, creatorId, callback) ->
    criteria =
      name: name
      creator_id: creatorId
    @findOne criteria, (error, board) =>
      if board?
        callback board
      else
        board = new Board(criteria)
        board.save (error) ->
          callback board

  findByName: (name, callback) ->
    @findOne name: name, (error, attributes) =>
      callback new Board(attributes)

BoardSchema.methods =
  destroy: (callback) ->
    @deleted = true
    @save (error) ->
      callback()

  addGroup: (attributes, callback) ->
    @_id = null
    @groups.push attributes
    @save (error) ->
      callback attributes

#createGroup = 
  #groupId = new BSON.ObjectID()
  #groupWithId = {_id: groupId, name: name, cardIds: cardIds}
  #update = {$set: {}}
  #update['$set']['groups.' + groupId] = attributes

  #withCollection 'boards', (boards) ->
    #boards.update {name: boardName}, update, safe(callback), errorWrapper () -> callback groupWithId

#removeGroup = (boardName, _id, callback) ->
#update = {$unset: {}}
  #update['$unset']['groups.' + _id] = 1

  #withCollection 'boards', (boards) ->
    #boards.update {name: boardName}, update, safe(callback), errorWrapper(callback)

#updateGroup = (boardName, _id, name, cardIds, callback) ->
  #update = {$set: {}}
  #if name then update['$set']['groups.' + _id + '.name'] = name
  #if cardIds then update['$set']['groups.' + _id + '.cardIds'] = cardIds

  #withCollection 'boards', (boards) ->
    #boards.update {name: boardName}, update, safe(callback), errorWrapper(callback)

Board = connection.model 'Board', BoardSchema

module.exports = { Board }
