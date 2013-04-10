{ mongoose } = require './db'

identitySchema = new mongoose.Schema
  source: String

Identity = mongoose.model 'Identity', identitySchema

module.exports = Identity
