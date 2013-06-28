DB = require './helper'
crypto = require 'crypto'

User = require '../lib/models/user'

exports.up = (next) ->
  DB.find 'users', {_id: {$exists: true}}, (error, users) ->
    return next error if error?
    return next() if users.length isnt 0
    createUniqueUsers (err, uniqueUsers)->
      bindUsersToAuthors uniqueUsers, (err, ok)->
        return next error if error?
        next()

avatarFor = (handle)->
  md5 = crypto.createHash 'md5'
  md5.update handle
  "http://www.gravatar.com/avatar/#{md5.digest 'hex'}?d=monsterid"

newUserData = (username)->
  {
    identities: [
      {
        source: 'boardroom-legacy'
        sourceId: username
        username: username
        displayName: username
        avatar: avatarFor(username)
      }
    ]
  }

createUniqueUsers = (next)->
  uniqueUsers = {}
  DB.find 'cards', { _id: { $exists: true } }, (error, cards) ->
    return next error if error?
    if cards.length > 0
      for card in cards
        do (card) ->
          uniqueUsers[card.creator] = 1
          uniqueUsers[author] = 1 for author in card.authors if card.authors?
          uniqueUsers[author] = 1 for author in card.plusAuthors if card.plusAuthors?
    DB.find 'boards', { _id: { $exists: true } }, (error, boards) ->
      return next error if error?
      if boards.length > 0
        for board in boards
          do (board) ->
            uniqueUsers[board.creator] = 1
      count = 0
      numUniquUsers = Object.keys(uniqueUsers).length
      for username, x of uniqueUsers
        do (username)->
          User.create newUserData(username), (err, user)->
            uniqueUsers[username] = user
            next null, uniqueUsers if numUniquUsers is ++count

bindUsersToAuthors = (uniqueUsers, next)->
  DB.find 'cards', { _id: { $exists: true } }, (error, cards) ->
    return next error if error?
    if cards.length > 0
      for card in cards
        do (card) ->
          creator = uniqueUsers[card.creator]._id
          authors = (uniqueUsers[author]._id for author in card.authors if card.authors) || []
          plusAuthors = (uniqueUsers[plusAuthor]._id for plusAuthor in card.plusAuthors if card.plusAuthors) || []
          DB.update 'cards', {_id : card._id } , {$set : { creator, authors, plusAuthors }}, (error, num) ->
            return next error if error?

    DB.find 'boards', { _id: { $exists: true } }, (error, boards) ->
      return next error if error?
      if boards.length > 0
        for board in boards
          do (board) ->
            creator = uniqueUsers[board.creator]._id
            DB.update 'boards', { _id: board._id }, {$set : { creator }}, (error, num) ->
              return next error if error?
      next null, true