require 'fibrous'

class Handler

  socket: null

  constructor: (@modelClass, @modelName) ->

  registerAll: ->
    @register "#{@modelName}.create", @handleCreate
    @register "#{@modelName}.update", @handleUpdate
    @register "#{@modelName}.delete", @handleDelete

  register: (event, handler) ->
    console.log "Register handler for #{event}"
    @socket.on event, (data) ->
      console.log "Handling #{event} with:"
      console.log data
      handler event, data

  handleCreate: (event, payload) =>
    cid = payload.cid
    data = payload.data

    console.log 'event', event
    console.log 'payload', payload

    model = new @modelClass data
    model.save (error, card) =>
      return console.log error if error?
      @socket.emit event, model
      @socket.broadcast.emit event, model

  handleUpdate: (event, payload) =>
    id = payload.id
    cid = payload.cid
    data = payload.data

    console.log 'event', event
    console.log 'payload', payload

    @modelClass.findById data._id, (error, model) =>
      return console.log error if error?
      model.updateAttributes data, (error) =>
        return console.log error if error?
        @socket.broadcast.emit event, data

  afterDelete: (model) => # post delete hook
  handleDelete: (event, payload) =>
    id = payload.id

    console.log 'event', event
    console.log 'payload', payload
    @modelClass.findById id, (error, model) =>
      return console.log error if error?
      model.remove (error) =>
        return console.log error if error?
        @socket.emit event, id
        @socket.broadcast.emit event, id
        @afterDelete(model)

module.exports = Handler
