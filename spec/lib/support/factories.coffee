Board = require "#{__dirname}/../../../lib/models/board"
Card = require "#{__dirname}/../../../lib/models/card"
Factory = require 'factory-lady'

Factory.define 'board', Board,
  name: 'name-1'
  creator_id: 'creator-1'
  deleted: false

Factory.define 'deletedBoard', Board,
  name: 'name-2'
  creator_id: 'creator-2'
  deleted: true

Factory.define 'card', Card,
  boardName: 'name-1'
  author: 'author-1'
  x: 100
  y: 100
  text: 'text'
  deleted: false
  authors: ['author-2']

module.exports = Factory
