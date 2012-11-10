Handler = require './handler'
Board = require '../models/board'
Group = require '../models/group'
Card = require '../models/card'

class BoardHandler extends Handler

  constructor: ->
    super Board, 'board'

  registerAll: ->
    @register "#{@name}.merge-groups", @handleMergeGroups
    @register "#{@name}.move-card", @handleMoveCard
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

  handleMoveCard: (event, data) =>
    console.log "Card"
    console.log data.cardSourcePath
    console.log "new Group"
    console.log data.newGroupSourcePath
    Card.findById data.cardSourcePath.cardId, (error, cardModel) =>
      @socket.emit 'card.delete', data.cardSourcePath.cardId
      @socket.broadcast.emit 'card.delete', data.cardSourcePath.cardId
      oldGroupId = cardModel.groupId
      # add card to new group
      cardModel.groupId = data.newGroupSourcePath.groupId
      cardModel.save (error, card)=>
        throw error if error?
        # update clients with the content of the new groups
        Card.findByGroupId card.groupId, (err, cards) =>
          throw error if error?
          payload = 
            groupId: data.newGroupSourcePath.groupId
            cards: cards
          @socket.emit 'group.update-cards', payload
          @socket.broadcast.emit 'group.update-cards', payload
        #remove old group if it is now empty
        Card.findByGroupId oldGroupId, (err, cards) =>
          throw error if error?
          return if cards? and cards.length
          Group.findById oldGroupId, (err, group) => 
            throw error if error?
            group.remove (error) =>
              throw error if error?
              @socket.emit 'group.delete', oldGroupId
              @socket.broadcast.emit 'group.delete', oldGroupId


module.exports = BoardHandler
