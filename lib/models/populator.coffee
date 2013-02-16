Board = require './board'
Group = require './group'
Card  = require './card'

class Populator
  constructor: () ->

  populate: (callback, cardinality="*") ->
    return undefined unless callback? 
    (error, boardCursor) =>
      if 1 is cardinality
        @populateOne callback, boardCursor
      else
        @populateMany callback, boardCursor

  populateMany: (callback, boards) ->
    return (callback null, []) unless boards? and 0 isnt boards?.length
    count = 0
    for board in boards
      do (board) =>
        @fillBoard board, (error, board) ->
          return callback error if error?
          count += 1
          callback null, boards if count == boards.length

  populateOne: (callback, board) ->
    return callback null, null unless board?
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
            if count == groups.length
              callback null, board 

  fillGroup: (group, callback) ->
    Card.find { groupId: group.id }, (error, cards) ->
      return callback error if error?
      group.cards = cards
      callback null, group

module.exports = Populator
