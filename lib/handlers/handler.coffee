class Handler

  namespace: null
  socket: null

  constructor: (@modelClass, @name) ->

  registerAll: ->
    @register "#{@name}.create", @handleCreate
    @register "#{@name}.update", @handleUpdate
    @register "#{@name}.delete", @handleDelete

  register: (event, handler) ->
    console.log "Register handler for #{event}"
    @socket.on event, (data) ->
      console.log "Handling #{event} with #{data}"
      handler event, data

  handleCreate: (event, data) =>

  handleUpdate: (event, data) =>

  handleDelete: (event, id) =>
    @modelClass.findById id, (error, model) =>
      throw error if error?
      model.remove (error) =>
        throw error if error?
        @namespace.emit event, id

module.exports = Handler
