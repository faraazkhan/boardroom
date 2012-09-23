DB = require './helper'

exports.up = (next) ->
  DB.update 'boards', { title: { $exists: true } }, { $unset: { title: 1 } }, (error, num) ->
    console.log "Removed title attribute from #{num} boards" if num > 0
    next()

exports.down = (next) ->
  console.log 'Cannot roll back this migration'
  next()
