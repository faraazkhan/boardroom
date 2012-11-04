Board = require './board'
Group = require './group'
Card  = require './card'

class Populator
  constructor: () ->

  populate: (callback) ->
    return undefined unless callback?
    (error, boards) =>
      if 'object' is typeof boards
        if boards._id? or (boards[0]? and !boards[1]?)
          @populateOne callback, boards
        else if boards[0]? and boards[1]?
          @populateMany callback, boards
        else
          return callback error, []
      else
        return callback error, []

  populateMany: (callback, boards) ->
    count = 0
    for board in boards
      do (board) =>
        @fillBoard board, (error, board) ->
          return callback error if error?
          count += 1
          callback null, boards if count == boards.length

  populateOne: (callback, board) ->
    @fillBoard board, (error, board) ->
      return callback error if error?
      callback error, board

  fillBoard: (board, callback) ->
    Group.find { boardId: board.id }, (error, groups) =>
      return callback error if error?
      board.groups = []
      return callback error, board if groups.length == 0
      count = 0
      for group in groups
        do (group) =>
          @fillGroup group, (error, group) ->
            return callback error if error?
            board.groups.push group
            count += 1
            callback null, board if count == groups.length

  fillGroup: (group, callback) ->
    Card.find { groupId: group.id }, (error, cards) ->
      return callback error if error?
      group.cards = cards
      callback null, group

module.exports = Populator
