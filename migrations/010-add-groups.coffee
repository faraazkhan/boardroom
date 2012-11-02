DB = require './helper'

exports.up = (next) ->
  DB.find 'cards', { boardId: { $exists: true } }, (error, cards) ->
    return next error if error?
    return next() if cards.length == 0
    count = 0
    for card in cards
      do (card) ->
        group = { name: null, boardId: card.boardId, x: card.x, y: card.y, z: card.z }
        DB.insert 'groups', group, (error, group) ->
          return next error if error?
          update =
            $set:
              groupId: group[0]._id.toString()
            $unset:
              boardId: 1
              x: 1
              y: 1
              z: 1
          DB.update 'cards', { _id: card._id }, update, (error, card) ->
            return next error if error?
            count += 1
            if count == cards.length
              console.log "  Created #{count} card groups"
              next()
