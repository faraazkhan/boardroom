io = require 'socket.io-client'
random = require './random'

class Monkey

  constructor: (@index, @boardId, url, @events) ->
    @running = false
    @socket = io.connect url, { 'force new connection': true }
    @socket.on 'connect', @onConnect
    @socket.on 'join', @onJoin
    @socket.on 'group.create', @onGroupCreate
    @socket.on 'card.create', @onCardCreate
    @hit 'connect'
    @group = @card = null
    @userId = "#{@index}"

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

  hit: (command) =>
    process.send { cmd: 'hit', command }

  #----- Socket handlers -----#

  onConnect: =>
    process.send { cmd: 'connect' }

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
    @hit 'join'

  createGroup: =>
    return unless @running
    @socket.emit 'group.create', { @boardId, x: random.x(), y: random.y(), z: @index, cid: @index }

  createCard: =>
    return unless @running
    @socket.emit 'card.create', { @boardId, groupId: @group._id, colorIndex: random.color(), text: @userId, cid: @index }
    @hit 'create'

  updateGroup: =>
    return unless @running
    r = random.number 0, 6
    @editCard() if r == 0
    @colorizeCard() if r == 1
    @moveGroup() if r > 1
    @hit 'update'

  moveGroup: =>
    x = Math.abs(@group.x += random.move())
    x = 800 - (x - 800) if x > 800
    y = Math.abs(@group.y += random.move())
    y = 500 - (y - 500) if y > 500
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
    @hit 'delete'

  #----- Load generator -----#

  startBanging: ->
    delay = ( 1000 * 60 ) / @events
    bang = =>
      if @running
        @updateGroup()
        @pause bang, delay
      else
        @pause @deleteGroup, 1000
    @pause bang

module.exports = Monkey
