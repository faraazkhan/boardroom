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
      boardModel.mergeGroups data.parentGroupId, data.otherGroupId, (error, parentGroup) =>
        throw error if error?

module.exports = BoardHandler
