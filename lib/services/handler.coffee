logger = require './logger'

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
    model.save (err, model) =>
      if err?
        logger.error => "Cannot save #{@name}:"
        logger.logValidationErrors err.errors
      else
        message = model.toJSON()
        message.cid = data.cid
        @socket.emit event, message
        @socket.broadcast.emit event, message

  handleUpdate: (event, data) =>
    @modelClass.findById data._id, (err, model) =>
      throw err if err?
      if model
        model.updateAttributes data, (err, model) =>
          if err?
            logger.error => "Cannot update #{@name}:"
            logger.logValidationErrors err.errors
          else
            @socket.broadcast.emit event, data
      else
        logger.error => "#{event}: missing #{@name}: #{data._id}"

  handleDelete: (event, id) =>
    count = 0
    doDelete = () =>
      count += 1
      @modelClass.findById id, (err, model) =>
        throw err if err?
        if model
          model.isRemovable (removable) =>
            if removable
              model.remove (err) =>
                throw err if err?
                logger.debug -> "#{event}: deleted successfully"
                @socket.broadcast.emit event, id
            else
              logger.debug -> "#{event}: unable to delete, try again in 100ms"
              setTimeout doDelete, 100 unless count > 10
        else
          logger.error => "#{event}: missing #{@name}: #{id}"

    doDelete()

module.exports = Handler
