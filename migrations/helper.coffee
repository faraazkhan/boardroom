MongoClient = require('mongodb').MongoClient

mongo = (callback) ->
  if DB.connection?
    callback null, DB.connection
  else
    console.log "MongoClient not connected.  You must call DB.connect()"

DB = {}

DB.connection = null

DB.connect = (callback) ->
  db_name = "boardroom_#{process.env['NODE_ENV'] || 'development'}"
  MongoClient.connect "mongodb://localhost:27017/#{db_name}", { db: { w: 'majority' } }, (error, db) ->
    DB.connection = db
    callback error

DB.disconnect = () ->
  DB.connection.close() if DB.connection?

DB.find = (colName, query, callback) ->
  withCollection colName, (error, col) ->
    col.find(query).toArray (error, items) ->
      callback error, items

DB.insert = (colName, documents, callback) ->
  withCollection colName, (error, col) ->
    col.insert documents, { safe: true}, (error, docs) ->
      callback error, docs

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
