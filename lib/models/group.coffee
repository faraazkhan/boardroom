{ withCollection,
  errorWrapper,
  safe,
  BSON } = require './db'

createGroup = (boardName, name, cardIds, callback) ->
  group = {name: name, cardIds: cardIds}
  groupId = new BSON.ObjectID()
  groupWithId = {_id: groupId, name: name, cardIds: cardIds}
  update = {$set: {}}
  update['$set']['groups.' + groupId] = group

  withCollection 'boards', (boards) ->
    boards.update {name: boardName}, update, safe(callback), errorWrapper () -> callback groupWithId

removeGroup = (boardName, _id, callback) ->
  update = {$unset: {}}
  update['$unset']['groups.' + _id] = 1

  withCollection 'boards', (boards) ->
    boards.update {name: boardName}, update, safe(callback), errorWrapper(callback)

updateGroup = (boardName, _id, name, cardIds, callback) ->
  update = {$set: {}}
  if name then update['$set']['groups.' + _id + '.name'] = name
  if cardIds then update['$set']['groups.' + _id + '.cardIds'] = cardIds

  withCollection 'boards', (boards) ->
    boards.update {name: boardName}, update, safe(callback), errorWrapper(callback)

module.exports = {
  createGroup
  removeGroup
  updateGroup
}
