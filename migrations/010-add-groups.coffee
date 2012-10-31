DB = require './helper'

exports.up = (next) ->
  DB.find 'cards', { boardId: { $exists: true } }, (error, cards) ->
    return next error if error?
    return next() if cards.length == 0
    count = 0
    for card in cards
      do (card) ->
        boardId = card.boardId
        cardId = card._id
        DB.insert 'groups', { name: null, boardId }, (error, group) ->
          return next error if error?
          update =
            $set:
              groupId: group[0]._id
            $unset:
              boardId: 1
          DB.update 'cards', { _id: cardId }, update, (error, card) ->
            return next error if error?
            count += 1
            if count == cards.length
              console.log "  Created #{count} card groups"
              next()
