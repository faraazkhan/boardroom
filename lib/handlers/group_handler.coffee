Handler = require './handler'
Group = require '../models/group'
Card = require '../models/card'

class GroupHandler extends Handler

  constructor: ->
    super Group, 'group'

  handleCreate: (event, data) =>
    group = new Group { boardId: data.boardId, x: data.x, y: data.y, z: data.z }
    group.save (error, group) =>
      throw error if error?
      card = new Card { groupId: group.id, creator: data.creator, focus: data.focus }
      card.save (error, card) =>
        throw error if error?
        group.cards = [card]
        message = group.toObject(getters: true)
        @socket.emit event, message
        @socket.broadcast.emit event, message

module.exports = GroupHandler
