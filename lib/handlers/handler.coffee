require 'fibrous'

class Handler

  socket: null

  constructor: (@modelClass, @name) ->

  registerAll: ->
    @register "#{@name}.create", @handleCreate
    @register "#{@name}.update", @handleUpdate
    @register "#{@name}.delete", @handleDelete

  register: (event, handler) ->
    # console.log "Register handler for #{event}"
    @socket.on event, (data) ->
      # console.log "Handling #{event} with:"
      # console.log data
      handler event, data

  handleCreate: (event, data) =>
    model = new @modelClass data
    model.sync.save()
    @socket.emit event, model
    @socket.broadcast.emit event, model

  handleUpdate: (event, data) =>
    @modelClass.findById data._id, (error, model) =>
      throw error if error?
      model.updateAttributes data, (error) =>
        throw error if error?
        @socket.broadcast.emit event, data

  handleDelete: (event, id) =>
    @modelClass.findById id, (error, model) =>
      throw error if error?
      model.remove (error) =>
        throw error if error?
        @socket.emit event, id
        @socket.broadcast.emit event, id

module.exports = Handler
