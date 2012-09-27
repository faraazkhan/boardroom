DB = require './helper'

exports.up = (next) ->
  date = new Date(2012, 8, 1)
  sem = 0

  DB.update 'boards', { created: { $exists: false } }, { $set: { created: date } }, (error, num) ->
    console.log "  Back-filled #{num} board.created attributes" if num > 0
    DB.update 'boards', { updated: { $exists: false } }, { $set: { updated: date } }, (error, num) ->
      console.log "  Back-filled #{num} board.updated attributes" if num > 0
      sem += 1
      next() if sem == 2

  DB.update 'cards', { created: { $exists: false } }, { $set: { created: date } }, (error, num) ->
    console.log "  Back-filled #{num} card.created attributes" if num > 0
    DB.update 'cards', { updated: { $exists: false } }, { $set: { updated: date } }, (error, num) ->
      console.log "  Back-filled #{num} card.updated attributes" if num > 0
      sem += 1
      next() if sem == 2
