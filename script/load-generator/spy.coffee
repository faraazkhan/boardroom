io = require 'socket.io-client'

class Spy

  constructor: (url, @sessionCount, @workers) ->
    @running = true
    @socket = io.connect url, { 'force new connection': true }
    @socket.on 'join', @onJoin
    @socket.on 'card.create', @onCardCreate
    @socket.on 'card.update', @onReceiveUpdate
    @socket.on 'group.update', @onReceiveUpdate
    @socket.on 'group.delete', @onGroupDelete

    @commands = [ 'connect', 'join', 'create', 'update', 'delete' ]
    @stats = {}
    @stats[command] = { send: 0, receive: 0 } for command in @commands

    @progressInt = setInterval @checkProgress, 2000

  hit: (direction, command) =>
    @stats[command][direction] += 1

  onConnect: =>
    @hit 'receive', 'connect'
    if @stats.connect.receive == @sessionCount
      worker.send { cmd: 'start' } for worker in @workers.all

  onJoin: =>
    @hit 'receive', 'join'

  onCardCreate: (message) =>
    @hit 'receive', 'create'

  onReceiveUpdate: (message) =>
    @hit 'receive', 'update'

  onGroupDelete: (message) =>
    i = message.index
    worker = @workers.get i
    worker.send { cmd: 'disconnect', body: i }
    @hit 'receive', 'delete'

  checkProgress: =>
    msg = "#{@sessionCount} sessions: "
    for cmd, i in @commands
      msg += cmd + " (#{@stats[cmd].send} / #{@stats[cmd].receive})"
      msg += ', ' unless i == @commands.length - 1
    console.log msg
    if !@running && @stats.delete.receive == @stats.create.receive
      @exit()

  exit: =>
    console.log 'all done'
    @socket.disconnect()
    clearInterval @progressInt
    process.exit()

  stop: =>
    @running = false

module.exports = Spy
