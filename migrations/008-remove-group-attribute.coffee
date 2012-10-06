DB = require './helper'

exports.up = (next) ->
  DB.update 'boards', { groups: { $exists: true } }, { $unset: { groups: 1 } }, (error, num) ->
    console.log "Removed groups attribute from #{num} boards" if num > 0
    next()
