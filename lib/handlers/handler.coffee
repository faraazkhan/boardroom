require 'fibrous'

class Handler

  socket: null

  constructor: (@modelClass, @name) ->

  registerAll: ->
    #broadcastEmit = @socket.broadcast.emit
    #@socket.broadcast.emit = (event, data) ->
    #  data.broadcast = true if data?
    #  broadcastEmit.call @, event, data

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
    model.save (error, card) =>
      throw error if error?
      @socket.emit event, model
      @socket.broadcast.emit event, model

  handleUpdate: (event, data) =>
    console.log "handleUpdate: #{event}"
    console.log data
    @modelClass.findById data._id, (error, model) =>
      throw error if error?
      model.updateAttributes data, (error) =>
        throw error if error?
        @socket.broadcast.emit event, data

  afterDelete: (model) => # post delete hook
  handleDelete: (event, id) =>
    console.log "handleDelete: #{event} - #{id}"
    count = 0
    doDelete = () =>
      count += 1
      @modelClass.findById id, (error, model) =>
        throw error if error?
        model.isRemovable (removable) =>
          if removable
            model.remove (error) =>
              throw error if error?
              console.log "did delete"
              @socket.broadcast.emit event, id
              @afterDelete(model)
          else
            console.log "did not delete"
            setTimeout doDelete, 100 unless count > 10

    doDelete()

module.exports = Handler
