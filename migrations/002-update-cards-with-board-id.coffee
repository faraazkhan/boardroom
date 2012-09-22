DB = require './helper'

exports.up = (next) ->
  DB.find 'boards', {}, (error, boards) ->
    return next error if error?
    next() if boards.length == 0
    count = 0
    for board in boards
      do (board) ->
        DB.update 'cards', { boardName: board.name }, { $set: { boardId: board._id.toHexString(), boardName: null } }, (error, num) ->
          return next error if error?
          console.log "Updated #{num} cards in board #{board.name}"
          count += 1
          next() if count == boards.length

exports.down = (next) ->
  DB.find 'boards', {}, (error, boards) ->
    return next error if error?
    next() if boards.length == 0
    count = 0
    for board in boards
      do (board) ->
        DB.update 'cards', { boardId: board._id }, { $set: { boardName: board.name, boardId: null } }, (error, num) ->
          return next error if error?
          console.log "Updated #{num} cards in board #{board.name}"
          count += 1
          next() if count == boards.length
