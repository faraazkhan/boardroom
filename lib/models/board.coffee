{ mongoose } = require './db'
Populator = require "./populator"
Card = require "./card"
Group = require "./group"

BoardSchema = new mongoose.Schema
  name: String
  creator: String
  created: Date
  updated: Date

BoardSchema.virtual('groups').get () -> @vGroups
BoardSchema.virtual('groups').set (groups) -> @vGroups = groups

BoardSchema.virtual('cards').get () -> @vCards
BoardSchema.virtual('cards').set (cards) -> @vCards = cards

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
  collaborators: ->
    collabs = []
    ( ( collabs.push user unless ( user == @creator or collabs.indexOf(user) >= 0 ) ) \
      for user in card.authors ) for card in @cards
    collabs

  lastUpdated: ->
    up = @updated
    up = ( if up.getTime() > card.updated.getTime() then up else card.updated ) for card in @cards
    up

  updateAttributes: (attributes, callback) ->
    for attribute in ['name'] when attributes[attribute]?
      @[attribute] = attributes[attribute]
    @save (error, card) ->
      callback error, card

  mergeGroups: (parentGroupId, otherGroupId, callback) ->
    parentGroup = otherGroup = null
    for group in @groups
      parentGroup = group if parentGroupId is group.id
      otherGroup = group if otherGroupId is group.id
    return callback (new Error "Parent group not found") unless parentGroup?
    return callback (new Error "Other group not found") unless otherGroup?

    count = 0
    for otherCard in otherGroup.cards # add otherCards into parentGroup
      do (otherCard) ->
        parentGroup.addCard otherCard, ->
          count +=1
          if count == otherGroup.cards.length
            Group.findById otherGroup.id, (error, model) => model.remove (error) if model? # delete otherGroup
            Group.findById parentGroup.id, callback

Board = mongoose.model 'Board', BoardSchema

module.exports = Board
