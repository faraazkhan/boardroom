mongodb = require 'mongodb'
server = new mongodb.Server 'localhost', 27017
db = new mongodb.Db "boardroom_#{process.env.NODE_ENV || 'development'}", server
db_instance = null
mongo = (callback) ->
  return callback(null, db_instance) if db_instance?
  db.open (error, connection) ->
    db_instance = connection
    callback error, connection

DB = {}

DB.find = (colName, query, callback) ->
  withCollection colName, (error, col) ->
    col.find(query).toArray (error, items) ->
      callback error, items

DB.update = (colName, query, update, callback) ->
  withCollection colName, (error, col) ->
    col.update query, update, { safe: true, upsert: false, multi: true }, (error, num) ->
      callback error, num

DB.remove = (colName, query, callback) ->
  withCollection colName, (error, col) ->
    col.remove query, { safe: true }, (error, num) ->
      callback error, num

DB.aggregate = (colName, query, callback) ->
  withCollection colName, (error, col) ->
    col.aggregate query, callback

withCollection = (colName, callback) ->
  mongo (error, db) ->
    db.collection colName, (error, col) ->
      return callback error if error?
      callback error, col

module.exports = DB
