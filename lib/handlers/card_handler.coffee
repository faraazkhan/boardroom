Handler = require './handler'
Card = require '../models/card'

class CardHandler extends Handler

  constructor: ->
    super Card, 'card'

module.exports = CardHandler
