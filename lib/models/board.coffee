{ mongoose } = require './db'
Populator = require "./populator"
Card = require "./card"
Group = require "./group"

BoardSchema = new mongoose.Schema
  name     : { type: String, required: true }
  _creator : { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
  creator  : { type: String }
  created  : { type: Date }
  updated  : { type: Date }

BoardSchema.virtual('groups').get () -> @vGroups
BoardSchema.virtual('groups').set (groups) -> @vGroups = groups


BoardSchema.virtual('currentUserId').get () -> @vCurrentUserId
BoardSchema.virtual('currentUserId').set (currentUserId) -> @vCurrentUserId = currentUserId
BoardSchema.virtual('userIdentitySet').get () -> @vUserIdentitySet
BoardSchema.virtual('userIdentitySet').set (userIdentitySet) -> @vUserIdentitySet = userIdentitySet


BoardSchema.pre 'save', (next) ->
  @created = new Date() unless @created?
  @updated = new Date()
  next()

BoardSchema.pre 'remove', (next) ->
  Group.findByBoardId @id, (error, groups) ->
    next error if error?
    return next() if !groups || groups.length == 0
    count = 0
    for group in groups
      do (group) ->
        group.remove (error) ->
          count += 1
          next() if count == groups.length

BoardSchema.statics =
  findById: (id, callback) ->
    @findOne { _id: id }, @populateOne(callback)

  createdBy: (user, callback) ->
    @find { creator: user }, null, { sort: 'name' }, @populateMany(callback)

  collaboratedBy: (user, callback) ->
    Group.collaboratedBy user, (error, groups) =>
      return callback error, null if error?
      boardIds = ( group.boardId for group in groups )
      @find { _id: { $in: boardIds }, creator: { $ne: user } }, null, { sort: 'name' }, @populateMany(callback)

  populateOne: (callback) ->
    new Populator().populate callback, 1

  populateMany: (callback) ->
    new Populator().populate callback, "*"

BoardSchema.methods =
  cards: ->
    cards = []
    cards = cards.concat(group.cards) for group in @groups
    cards

  collaborators: ->
    collabs = []
    for card in @cards()
      for userId in card.authors
        continue unless userId?
        collabId = collabId?.toString()
        collabs.push collabId unless ( collabId == @creator or collabId in collabs )
    collabs

  lastUpdated: ->
    up = @updated
    up = ( if up.getTime() > card.updated.getTime() then up else card.updated ) for card in @cards()
    up

  updateAttributes: (attributes, callback) ->
    for attribute in ['name'] when attributes[attribute]?
      @[attribute] = attributes[attribute]
    @save (error, card) ->
      callback error, card

Board = mongoose.model 'Board', BoardSchema

module.exports = Board
