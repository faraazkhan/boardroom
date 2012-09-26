DB = require './helper'

exports.up = (next) ->
  DB.update 'boards', { deleted: { $exists: true } }, { $unset: { deleted: 1 } }, (error, num) ->
    console.log "Removed deleted attribute from #{num} boards" if num > 0
    next()
