Handler = require './handler'
Path = require '../models/path'

class PathHandler extends Handler

  constructor: ->
    super Path, 'path'

module.exports = PathHandler
