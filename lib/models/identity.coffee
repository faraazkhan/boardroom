{ mongoose } = require './db'

identitySchema = new mongoose.Schema
  source: String
  sourceId: String
  username: String
  displayName: String
  avatar: String
  email: String

Identity = mongoose.model 'Identity', identitySchema

module.exports = Identity
