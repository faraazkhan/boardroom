{ withCollection,
  errorWrapper,
  safe,
  BSON } = require './db'

findBoards = (criteria, reducer) ->
  withCollection 'boards', (coll) ->
    coll.find criteria, errorWrapper (cursor) ->
      cursor.each errorWrapper reducer

findBoardCardCounts = (callback) ->
  withCollection 'cards', (cards) ->
    cards.group({boardName:true}, {}, { count:0 }, ((item,stats) -> stats.count++), errorWrapper(callback))

findOrCreateBoard = (boardName, creator_id, callback) ->
  withCollection 'boards', (collection) ->
    collection.find({ name: boardName }, { limit: 1 }).toArray (err, objs) ->
      if objs.length == 0
        b = { name: boardName, title: boardName, creator_id: creator_id }
        collection.insert b
        callback b
      else
        callback objs[0]

findBoard = (boardName, callback) ->
  withCollection 'boards', (collection) ->
    collection.find({ name: boardName }, { limit: 1 }).toArray (err, objs) ->
      if objs.length > 0 then callback objs[0]

findBoardAllowEmpty = (boardName, callback) ->
  withCollection 'boards', (collection) ->
    collection.findOne { name: boardName }, errorWrapper (board) -> callback board

updateBoard = (boardName, attrs, callback) ->
  withCollection 'boards', (collection) ->
    collection.update { name: boardName }, { $set: attrs }, safe(callback), errorWrapper callback

deleteBoard = (boardId, callback) ->
  withCollection 'boards', (collection) ->
    collection.update { _id:new BSON.ObjectID(boardId) }, { $set: {'deleted':true} }, safe(callback), errorWrapper callback

module.exports = {
  findBoards
  findBoardCardCounts
  findOrCreateBoard
  findBoard
  findBoardAllowEmpty
  updateBoard
  deleteBoard
}
