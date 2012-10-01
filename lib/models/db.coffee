mongoose = require 'mongoose'

db = mongoose.createConnection 'localhost',
  "boardroom_#{process.env['NODE_ENV'] || 'development'}"

db.on 'error', (error) ->
  console.log "Mongoose error: #{error.trace}"

module.exports = { mongoose, db }
