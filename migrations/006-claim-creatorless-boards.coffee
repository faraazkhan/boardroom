DB = require './helper'

exports.up = (next) ->
  DB.update 'boards', { creator: { $exists: false } }, { $set: { creator: '@mwynholds' } }, (error, num) ->
    console.log "  Claimed #{num} creator-less boards" if num > 0
    next()
