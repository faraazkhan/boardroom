{ mongoose } = require './db'
Populator = require "./populator"
Card = require "./card"
Group = require "./group"

BoardSchema = new mongoose.Schema
  name    : { type: String, required: true }
  creator : { type: String, required: true }
  created : { type: Date }
  updated : { type: Date }

BoardSchema.virtual('groups').get () -> @vGroups
BoardSchema.virtual('groups').set (groups) -> @vGroups = groups

BoardSchema.pre 'save', (next) ->
  console.log "Saving"
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
    ( ( collabs.push user unless ( user == @creator or collabs.indexOf(user) >= 0 ) ) \
      for user in card.authors ) for card in @cards()
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
