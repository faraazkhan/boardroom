mongo = require('mongodb')
BSON = mongo.BSONPure
mongoUrl = "mongodb://localhost/boardroom_#{(process.env['NODE_ENV'] || 'development')}"

errorWrapper  = (handler) ->
  return (error) ->
    if error
      return console.log "DB ERROR", (if error.message then error.message else error)
    if handler
      handler.apply this, Array.prototype.slice.apply( arguments, [1] )

database = null
mongo.connect mongoUrl, errorWrapper (_database) -> database = _database

withCollection = (name, callback) -> database.collection name, errorWrapper callback

safe = (callback) ->
  if callback
    safe: true
  else
    {}

exports.saveCard = (card, callback) ->
  withCollection 'cards', (cards) ->
    card.authors = [];
    cards.save card, safe(callback), errorWrapper callback

exports.updateCard = (card, callback) ->
  withCollection 'cards', (cards) ->
    cards.find {_id:new BSON.ObjectID(card._id) }, errorWrapper ( cursor ) ->
      cursor.each errorWrapper ( existingCard ) ->
        if existingCard == null then return
        if card.x then existingCard.x = card.x
        if card.y then existingCard.y = card.y
        if card.text then existingCard.text = card.text
        if card.colorIndex then existingCard.colorIndex = card.colorIndex
        if card.deleted != null then existingCard.deleted = card.deleted
        if card.author && (! existingCard.authors || ! (existingCard.authors.indexOf(card.author)>-1))
          (existingCard.authors=existingCard.authors||[]).push( card.author );
        cards.save existingCard, safe(callback), errorWrapper callback

exports.removeCard = (card, callback) ->
  withCollection 'cards', (cards) -> cards.remove { _id: new BSON.ObjectID(card._id) }, errorWrapper callback

exports.arrayReducer = (complete, array = []) ->
  return (item) ->
    if item != null then return array.push(item)
    if complete then return complete array

exports.findCards = (criteria, reducer) ->
  withCollection 'cards', (cards) ->
    cards.find criteria, errorWrapper (cursor) ->
      cursor.each errorWrapper reducer

exports.findBoards = (criteria, reducer) ->
  withCollection 'boards', (coll) ->
    coll.find criteria, errorWrapper (cursor) ->
      cursor.each errorWrapper reducer

exports.findBoardCardCounts = (callback) ->
  withCollection 'cards', (cards) ->
    cards.group({boardName:true}, {}, { count:0 }, ((item,stats) -> stats.count++), errorWrapper(callback))

exports.findOrCreateBoard = (boardName, creator_id, callback) ->
  withCollection 'boards', (collection) ->
    collection.find({ name: boardName }, { limit: 1 }).toArray (err, objs) ->
      if objs.length == 0
        b = { name: boardName, title: boardName, creator_id: creator_id }
        collection.insert b
        callback b
      else
        callback objs[0]

exports.findBoard = (boardName, callback) ->
  withCollection 'boards', (collection) ->
    collection.find({ name: boardName }, { limit: 1 }).toArray (err, objs) ->
      if objs.length > 0 then callback objs[0]

exports.findBoardAllowEmpty = (boardName, callback) ->
  withCollection 'boards', (collection) ->
    collection.findOne { name: boardName }, errorWrapper (board) -> callback board

exports.updateBoard = (boardName, attrs, callback) ->
  withCollection 'boards', (collection) ->
    collection.update { name: boardName }, { $set: attrs }, safe(callback), errorWrapper callback

exports.deleteBoard = (boardId, callback) ->
  withCollection 'boards', (collection) ->
    collection.update { _id:new BSON.ObjectID(boardId) }, { $set: {'deleted':true} }, safe(callback), errorWrapper callback

exports.createGroup = (boardName, name, cardIds, callback) ->
  group = {name: name, cardIds: cardIds}
  groupId = new BSON.ObjectID()
  groupWithId = {_id: groupId, name: name, cardIds: cardIds}
  update = {$set: {}}
  update['$set']['groups.' + groupId] = group

  withCollection 'boards', (boards) ->
    boards.update {name: boardName}, update, safe(callback), errorWrapper () -> callback groupWithId

exports.removeGroup = (boardName, _id, callback) ->
  update = {$unset: {}}
  update['$unset']['groups.' + _id] = 1

  withCollection 'boards', (boards) ->
    boards.update {name: boardName}, update, safe(callback), errorWrapper(callback)


exports.updateGroup = (boardName, _id, cardIds, callback) ->
  update = {$set: {}}
  update['$set']['groups.' + _id] = {cardIds: cardIds}

  withCollection 'boards', (boards) ->
    boards.update {name: boardName}, update, safe(callback), errorWrapper(callback)

