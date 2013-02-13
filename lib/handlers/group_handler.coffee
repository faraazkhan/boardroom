Handler = require './handler'
Group = require '../models/group'
Card = require '../models/card'

class GroupHandler extends Handler

  constructor: ->
    super Group, 'group'

module.exports = GroupHandler
