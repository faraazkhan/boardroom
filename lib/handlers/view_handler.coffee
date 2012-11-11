Handler = require './handler'

class ViewHandler extends Handler

  constructor: ->
    super null, 'view'  # abstract view handler (has no CRUD methods)

  registerAll: ->
    @register "view.add-indicator", @handleAddIndicator
    @register "view.remove-indicator", @handleRemoveIndicator

  handleAddIndicator: (event, data) =>
    @socket.broadcast.emit 'view.add-indicator', data

  handleRemoveIndicator: (event, data) =>
    @socket.broadcast.emit 'view.remove-indicator', data

module.exports = ViewHandler
