Handler = require './handler'
Board = require '../models/board'
Group = require '../models/group'
Card = require '../models/card'

class BoardHandler extends Handler

  constructor: ->
    super Board, 'board'

  registerAll: ->
    @register "board.group.merge", @handleGroupMerge
    @register "board.card.switch-groups", @handleCardSwitchGroups
    @register "board.card.ungroup", @handleCardUngroup
    super

  handleGroupMerge: (event, data) =>
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

  handleCardSwitchGroups: (event, data) =>
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

  handleCardUngroup: (event, data) =>
    Card.findById data.cardSourcePath.cardId, (error, cardModel) =>
      oldGroupId = data.cardSourcePath.groupId
      # add card to new group
      group = new Group { boardId: data.cardSourcePath.boardId, x: data.x, y: data.y, z: data.z }
      group.save (error, group) =>
        throw error if error?
        cardModel.groupId = group.id
        cardModel.save (error, card) =>
          throw error if error?
          group.cards = [card]
          message = group.toObject(getters: true)
          @socket.emit 'group.create', message
          @socket.broadcast.emit 'group.create', message
          @socket.emit 'card.delete', data.cardSourcePath.cardId
          @socket.broadcast.emit 'card.delete', data.cardSourcePath.cardId
          #remove old group if it is now empty
          Card.findByGroupId oldGroupId, (err, cards) =>
            throw error if error?
            return if cards? and cards.length
            Group.findById oldGroupId, (err, group) => 
              throw error if error?
              if group
                group.remove (error) =>
                  throw error if error?
                  @socket.emit 'group.delete', oldGroupId
                  @socket.broadcast.emit 'group.delete', oldGroupId
              else 
                console.log "cant remove group that doesn't exist!"

module.exports = BoardHandler
