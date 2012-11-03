Handler = require './handler'
Board = require '../models/board'

class BoardHandler extends Handler

  constructor: ->
    super Board, 'board'

  registerAll: ->
    @register "#{@name}.merge-groups", @handleMergeGroups
    super

  handleMergeGroups: (event, data) =>
    Board.findById data._id, (error, boardModel) =>
      throw error if error?
      console.log boardModel
      boardModel.mergeGroups data.parentGroupId, data.targetGroupId, (error, result) =>
        throw error if error?
        console.log result
      #   @socket.broadcast.emit event, data

module.exports = BoardHandler
