logger = require '../utils/logger'

class Handler

  socket: null

  constructor: (@modelClass, @name) ->

  registerAll: ->
    @register "#{@name}.create", @handleCreate
    @register "#{@name}.update", @handleUpdate
    @register "#{@name}.delete", @handleDelete

  register: (event, handler) ->
    @socket.on event, (data) ->
      logger.debug -> "handle: #{event} - #{JSON.stringify(data)}"
      handler event, data

  handleCreate: (event, data) =>
    model = new @modelClass data
    model.save (error, card) =>
      throw error if error?
      message = model.toJSON()
      message.cid = data.cid
      @socket.emit event, message
      @socket.broadcast.emit event, message

  handleUpdate: (event, data) =>
    @modelClass.findById data._id, (error, model) =>
      throw error if error?
      if model
        model.updateAttributes data, (error) =>
          throw error if error?
          @socket.broadcast.emit event, data
      else
        logger.error -> "#{event}: missing model: #{data._id}"

  handleDelete: (event, id) =>
    count = 0
    doDelete = () =>
      count += 1
      @modelClass.findById id, (error, model) =>
        throw error if error?
        if model
          model.isRemovable (removable) =>
            if removable
              model.remove (error) =>
                throw error if error?
                logger.debug -> "#{event}: deleted successfully"
                @socket.broadcast.emit event, id
            else
              logger.debug -> "#{event}: unable to delete, try again in 100ms"
              setTimeout doDelete, 100 unless count > 10
        else
          logger.error -> "#{event}: missing model: #{id}"

    doDelete()

module.exports = Handler
