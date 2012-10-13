Board = require "#{__dirname}/../../../lib/models/board"
Card = require "#{__dirname}/../../../lib/models/card"
Factory = require 'factory-lady'

Factory.define 'board', Board,
  name: 'name-1'
  creator: 'board-creator-1'

Factory.define 'card', Card,
  creator: 'card-creator-1'
  x: 100
  y: 100
  text: 'text'
  colorIndex: 2
  deleted: false
  authors: ['author-1']

Factory.createBundle = (callback) ->
  board1 = Factory.sync.create 'board', name: 'board1', creator: 'board-creator-1'
  board2 = Factory.sync.create 'board', name: 'board2', creator: 'board-creator-2'
  board3 = Factory.sync.create 'board', name: 'board3', creator: 'board-creator-3'
  board4 = Factory.sync.create 'board', name: 'board4', creator: 'board-creator-4'
  Factory.sync.create 'card', boardId: board1.id, authors: ['board-creator-1']
  Factory.sync.create 'card', boardId: board2.id, authors: ['board-creator-1', 'someotherguy']
  Factory.sync.create 'card', boardId: board3.id, authors: ['board-creator-1']
  Factory.sync.create 'card', boardId: board4.id, authors: ['nobody']
  callback null, null

module.exports = Factory
