Handler = require './handler'
Board = require '../models/board'
Group = require '../models/group'
Card = require '../models/card'

class BoardHandler extends Handler

  constructor: ->
    super Board, 'Board'

  registerAll: ->
    @register "Board.Group.merge", @handleGroupMerge
    @register "Board.Card.switch-groups", @handleCardSwitchGroups
    @register "Board.Card.ungroup", @handleCardUngroup
    super

  handleGroupMerge: (event, payload) =>
    id = payload.cid
    data = payload.data
    Board.findById id, (error, boardModel) =>
      return console.log error if error?
      boardModel.mergeGroups data.parentGroupId, data.otherGroupId, (error, parentGroup) =>
        return console.log error if error?
        @socket.emit 'group.delete', data.otherGroupId
        @socket.broadcast.emit 'group.delete', data.otherGroupId
        Card.findByGroupId parentGroup._id, (err, cards) =>
          return console.log error if error?
          payload = 
            groupId: parentGroup._id
            cards: cards
          @socket.emit 'group.update-cards', payload
          @socket.broadcast.emit 'group.update-cards', payload

  handleCardSwitchGroups: (event, payload) =>
    id = payload.cid
    data = payload.data
    Card.findById data.cardSourcePath.cardId, (error, cardModel) =>
      @socket.emit 'card.delete', data.cardSourcePath.cardId
      @socket.broadcast.emit 'card.delete', data.cardSourcePath.cardId
      oldGroupId = cardModel.groupId
      # add card to new group
      cardModel.groupId = data.newGroupSourcePath.groupId
      cardModel.save (error, card)=>
        return console.log error if error?
        # update clients with the content of the new groups
        Card.findByGroupId card.groupId, (err, cards) =>
          return console.log error if error?
          payload = 
            groupId: data.newGroupSourcePath.groupId
            cards: cards
          @socket.emit 'group.update-cards', payload
          @socket.broadcast.emit 'group.update-cards', payload
        #remove old group if it is now empty
        Card.findByGroupId oldGroupId, (err, cards) =>
          return console.log error if error?
          return if cards? and cards.length
          Group.findById oldGroupId, (err, group) => 
            return console.log error if error?
            group.remove (error) =>
              return console.log error if error?
              @socket.emit 'group.delete', oldGroupId
              @socket.broadcast.emit 'group.delete', oldGroupId

  handleCardUngroup: (event, payload) =>
    id = payload.cid
    data = payload.data

    Card.findById data.cardSourcePath.cardId, (error, cardModel) =>
      oldGroupId = data.cardSourcePath.groupId
      # add card to new group
      group = new Group { boardId: data.cardSourcePath.boardId, x: data.x, y: data.y, z: data.z }
      group.save (error, group) =>
        return console.log error if error?
        cardModel.groupId = group.id
        cardModel.save (error, card) =>
          return console.log error if error?
          group.cards = [card]
          message = group.toObject(getters: true)
          @socket.emit 'group.create', message
          @socket.broadcast.emit 'group.create', message
          @socket.emit 'card.delete', data.cardSourcePath.cardId
          @socket.broadcast.emit 'card.delete', data.cardSourcePath.cardId
          #remove old group if it is now empty
          Card.findByGroupId oldGroupId, (err, cards) =>
            return console.log error if error?
            return if cards? and cards.length
            Group.findById oldGroupId, (err, group) => 
              return console.log error if error?
              if group
                group.remove (error) =>
                  return console.log error if error?
                  @socket.emit 'group.delete', oldGroupId
                  @socket.broadcast.emit 'group.delete', oldGroupId
              else 
                console.log "cant remove group that doesn't exist!"

module.exports = BoardHandler
