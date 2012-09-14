mongoose = require 'mongoose'

db = mongoose.createConnection 'localhost',
  "boardroom_#{process.env['NODE_ENV'] || 'development'}"

module.exports = { mongoose, db }
