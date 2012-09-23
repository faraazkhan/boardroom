DB = require './helper'

exports.up = (next) ->
  DB.remove 'boards', { name: null }, (error, boards) ->
    DB.find 'boards', { deleted: true }, (error, boards) ->
      return next() if boards.length == 0
      count = 0
      for board in boards
        do (board) ->
          DB.remove 'boards', { _id: board._id }, (error, num) ->
            console.log "Removed board: #{board.name}" if num > 0
            DB.remove 'cards', { boardName: board.name }, (error, num) ->
              console.log "Remove #{num} cards from board #{board.name}" if num > 0
              count += 1
              next() if count == boards.length

exports.down = (next) ->
  console.log 'Cannot roll back this migration'
  next()
