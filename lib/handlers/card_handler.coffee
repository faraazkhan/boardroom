Handler = require './handler'
Card = require '../models/card'
Group = require '../models/group'

class CardHandler extends Handler

  constructor: ->
    super Card, 'Card'

  afterDelete: (model)=>  # Delete parent group if it is now empty 
    return unless model? and model.groupId?
    Card.findByGroupId model.groupId, (err, cards) =>
      return console.log error if error?
      return if cards? and 0<cards.length
      Group.findById model.groupId, (error, group) =>
        return console.log error if error?
        group?.remove (error) =>
          return console.log error if error?
          @socket.emit 'group.delete', model.groupId
          @socket.broadcast.emit 'group.delete', model.groupId

module.exports = CardHandler
