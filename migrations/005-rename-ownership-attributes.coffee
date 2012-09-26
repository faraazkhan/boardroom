DB = require './helper'

exports.up = (next) ->
  DB.update 'boards', { creator_id: { $exists: true } }, { $rename: { creator_id: 'creator' } }, (error, num) ->
    console.log "Renamed creator_id attribute on #{num} boards" if num > 0
    DB.update 'cards', { author: { $exists: true } }, { $rename: { author: 'creator' } }, (error, num) ->
      console.log "Renamed author attribute on #{num} cards" if num > 0
      next()
