mongo = require 'mongodb'
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

arrayReducer = (complete, array = []) ->
  return (item) ->
    if item != null then return array.push(item)
    if complete then return complete array

safe = (callback) ->
  if callback
    safe: true
  else
    {}

module.exports = {
  withCollection
  errorWrapper
  arrayReducer
  safe
  BSON
}
