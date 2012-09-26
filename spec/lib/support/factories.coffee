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

Factory.createBundle = (name, callback) ->
  if name == 'typical'
    Factory.create 'board', ->
      Factory.create 'board', creator: 'board-creator-2', (board2) ->
        Factory.create 'board', creator: 'board-creator-3', (board3) ->
          Factory.create 'card', boardId: board2.id, authors: [ 'board-creator-1' ], ->
            Factory.create 'card', boardId: board3.id, authors: [ 'nobody' ], ->
              callback()
  else
    callback()

module.exports = Factory
