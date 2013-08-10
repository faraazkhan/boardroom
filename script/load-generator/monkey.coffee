io = require 'socket.io-client'
random = require './random'

class Monkey

  constructor: (@index, @boardId, url, @events) ->
    @running = false
    @socket = io.connect url, { 'force new connection': true }
    @socket.on 'join', @onJoin
    @socket.on 'group.create', @onGroupCreate
    @socket.on 'card.create', @onCardCreate
    @group = @card = null
    @userId = "#{@index}"
    @start()

  start: ->
    @running = true
    @pause @join

  stop: ->
    @running = false

  disconnect: ->
    #console.log "Monkey #{@index} disconnecting..."
    @socket.disconnect()

  pause: (f, millis = null) ->
    setTimeout f, millis ? random.pause()

  #----- Socket handlers -----#

  onJoin: (message) =>
    if message.userId == @userId
      @pause @createGroup

  onGroupCreate: (message) =>
    if message.cid == @index
      @group = message
      @pause @createCard

  onCardCreate: (message) =>
    if message.cid == @index
      @card = message
      @startBanging()

  #----- Socket emitters -----#

  join: =>
    return unless @running
    @socket.emit 'join', { @userId, displayName: "Load Tester #{@userId}" }
    process.send { cmd: 'join' }

  createGroup: =>
    return unless @running
    @socket.emit 'group.create', { @boardId, x: random.x(), y: random.y(), z: @index, cid: @index }

  createCard: =>
    return unless @running
    @socket.emit 'card.create', { @boardId, groupId: @group._id, colorIndex: random.color(), text: @userId, cid: @index }

  updateGroup: =>
    return unless @running
    r = random.number 0, 6
    @editCard() if r == 0
    @colorizeCard() if r == 1
    @moveGroup() if r > 1
    process.send { cmd: 'update' }

  moveGroup: =>
    x = @group.x += random.move()
    y = @group.y += random.move()
    @socket.emit 'group.update', { _id: @group._id, @boardId, x, y }

  editCard: =>
    text = @card.text += random.char()
    @socket.emit 'card.update', { _id: @card._id, @boardId, text }

  colorizeCard: =>
    colorIndex = @card.colorIndex = (@card.colorIndex + 1) % 5
    @socket.emit 'card.update', { _id: @card._id, @boardId, colorIndex }

  deleteGroup: =>
    @socket.emit 'card.delete', { _id: @card._id, @boardId }
    @socket.emit 'group.delete', { _id: @group._id, @boardId, @index }
    process.send { cmd: 'delete' }

  #----- Load generator -----#

  startBanging: ->
    delay = ( 1000 * 60 ) / @events
    bang = =>
      @updateGroup()
      if @running
        @pause bang, delay
      else
        @pause @deleteGroup, 1000
    @pause bang

module.exports = Monkey
