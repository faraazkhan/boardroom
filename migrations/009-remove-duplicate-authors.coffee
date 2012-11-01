DB = require './helper'

uniq = (array) ->
  output = {}
  output[array[i]] = array[i] for i in [0...array.length]
  value for key, value of output

exports.up = (next) ->
  query = [
    { $project : { authors : 1 } },
    { $unwind : "$authors" },
    { $group : { _id : { id : "$_id", authors : "$authors" } , num : { $sum : 1 } } },
    { $match : { num : { $gt : 1 } } }
  ]
  DB.aggregate 'cards', query, (error, results) ->
    return next() unless results
    ids = uniq ( result._id.id for result in results )
    return next() if ids.length == 0
    DB.find 'cards', { _id: { $in: ids } }, (error, cards) ->
      count = 0
      for card in cards
        do (card) ->
          DB.update 'cards', { _id: card._id }, { $set : { authors: uniq card.authors } }, ->
            count += 1
            if count == ids.length
              console.log "  Updated #{ids.length} cards with duplicate authors"
              next()
