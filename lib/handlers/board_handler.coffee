Handler = require './handler'
Board = require '../models/board'
Card = require '../models/card'

class BoardHandler extends Handler

  constructor: ->
    super Board, 'board'

  registerAll: ->
    @register "#{@name}.merge-groups", @handleMergeGroups
    super

  handleMergeGroups: (event, data) =>
    Board.findById data._id, (error, boardModel) =>
      throw error if error?
      boardModel.mergeGroups data.parentGroupId, data.otherGroupId, (error, parentGroup) =>
        throw error if error?
        @socket.emit 'group.delete', data.otherGroupId
        @socket.broadcast.emit 'group.delete', data.otherGroupId
        Card.findByGroupId parentGroup._id, (err, cards) =>
          throw error if error?
          payload = 
            groupId: parentGroup._id
            cards: cards
          @socket.emit 'group.update-cards', payload
          @socket.broadcast.emit 'group.update-cards', payload

module.exports = BoardHandler
