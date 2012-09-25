Board = require "#{__dirname}/../../../lib/models/board"
Card = require "#{__dirname}/../../../lib/models/card"
Factory = require 'factory-lady'

Factory.define 'board', Board,
  name: 'name-1'
  creator_id: 'creator-1'

Factory.define 'card', Card,
  author: 'author-1'
  x: 100
  y: 100
  text: 'text'
  colorIndex: 2
  deleted: false
  authors: ['author-2']

module.exports = Factory
