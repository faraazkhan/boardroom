io = require 'socket.io-client'

class Spy


  constructor: (url, @sessionCount, @workers) ->
    @socket = io.connect url, { 'force new connection': true }
    @socket.on 'join', @onJoin
    @socket.on 'group.delete', @onGroupDelete
    @socket.on 'card.update', @onReceiveUpdate
    @socket.on 'group.update', @onReceiveUpdate

    @commands = [ 'connect', 'join', 'update', 'delete' ]
    @stats = {}
    @stats[command] = { send: 0, receive: 0 } for command in @commands

    @progressInt = setInterval @showProgress, 2000

  hit: (direction, command) =>
    @stats[command][direction] += 1

  onConnect: =>
    @hit 'receive', 'connect'
    if @stats.connect.receive == @sessionCount
      worker.send { cmd: 'start' } for worker in @workers.all

  onJoin: =>
    @hit 'receive', 'join'

  onGroupDelete: (message) =>
    i = message.index
    worker = @workers.get i
    worker.send { cmd: 'disconnect', body: i }
    @hit 'receive', 'delete'
    if @stats.delete.receive == @stats.join.receive
      setTimeout @stop, 1000

  onReceiveUpdate: (message) =>
    @hit 'receive', 'update'

  showProgress: =>
    msg = "#{@sessionCount} sessions: "
    for cmd, i in @commands
      msg += cmd + " (#{@stats[cmd].send} / #{@stats[cmd].receive})"
      msg += ', ' unless i == @commands.length - 1
    console.log msg

  stop: =>
    @showProgress()
    console.log 'all done'
    @socket.disconnect()
    clearInterval @progressInt
    process.exit()

module.exports = Spy
