mongoose = require 'mongoose'

mongoose.connect 'localhost',
  "boardroom_#{process.env['NODE_ENV'] || 'development'}"

mongoose.connection.on 'error', (error) ->
  console.log "Mongoose error: #{error.trace}"

module.exports = { mongoose }
