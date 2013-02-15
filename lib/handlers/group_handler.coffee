Handler = require './handler'
Group = require '../models/group'

class GroupHandler extends Handler

  constructor: ->
    super Group, 'group'

module.exports = GroupHandler
