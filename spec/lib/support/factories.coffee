Board = require "#{__dirname}/../../../lib/models/board"
Group = require "#{__dirname}/../../../lib/models/group"
Card = require "#{__dirname}/../../../lib/models/card"
Factory = require 'factory-lady'

Factory.define 'board', Board,
  name: 'name-1'
  creator: 'board-creator-1'

Factory.define 'group', Group,
  boardId: 0
  name: 'group-1'
  x: 100
  y: 100
  z: 1

Factory.define 'card', Card,
  groupId: 0
  creator: 'card-creator-1'
  text: 'text'
  colorIndex: 2
  deleted: false
  authors: ['factoryAuthor1']
  plusAuthors: ['factoryPlusAuthor1']

Factory.createBundle = (callback) ->
  authors = [ ['board-creator-1'],
              ['board-creator-1', 'someotherguy'],
              ['board-creator-1'],
              ['nobody']
            ]
  for i in [1..4]
    do (i) ->
      board = Factory.sync 'board', name: "board#{i}", creator: "board-creator-#{i}"
      group = Factory.sync 'group', boardId: board.id
      card = Factory.sync 'card', groupId: group.id, authors: authors[i-1]

  callback null, null

module.exports = Factory
