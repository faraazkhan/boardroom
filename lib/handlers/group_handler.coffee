Handler = require './handler'
Group = require '../models/group'
Card = require '../models/card'

class GroupHandler extends Handler

  constructor: ->
    super Group, 'Group'

  registerAll: ->
    @register "Group.Card.create", @handleCreateCard
    super

  handleCreate: (event, payload) =>
    cid = payload.cid
    data = payload.data

    group = new Group { boardId: data.boardId, x: data.x, y: data.y, z: data.z }
    group.save (error, group) =>
      return console.log error if error?
      card = new Card { groupId: group.id, creator: data.creator, focus: data.focus }
      card.save (error, card) =>
        return console.log error if error?
        group.cards = [card]
        message = group.toObject(getters: true)
        @socket.emit event, message
        @socket.broadcast.emit event, message

  handleCreateCard: (event, data) =>
    sourcePath = data.sourcePath
    card = new Card { groupId: data.sourcePath.groupId, creator: data.creator, focus: data.focus }
    card.save (error, card) =>
      return console.log error if error?
      Card.findByGroupId data.sourcePath.groupId, (err, cards) =>
        return console.log error if error?
        payload =
          groupId: data.sourcePath.groupId
          cards: cards
        @socket.emit 'group.update-cards', payload
        @socket.broadcast.emit 'group.update-cards', payload

module.exports = GroupHandler
