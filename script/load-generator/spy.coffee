io = require 'socket.io-client'

class Spy

  constructor: (url, @sessionCount, @workers) ->
    @socket = io.connect url, { 'force new connection': true }
    @socket.on 'join', @onJoin
    @socket.on 'group.delete', @onGroupDelete
    @socket.on 'card.update', @onReceiveUpdate
    @socket.on 'group.update', @onReceiveUpdate
    @stats =
      joins:   { sent: 0, received: 0 }
      updates: { sent: 0, received: 0 }
      deletes: { sent: 0, received: 0 }
    @progressInt = setInterval @showProgress, 5000

  onSendJoin: =>
    @stats.joins.sent += 1

  onSendUpdate: =>
    @stats.updates.sent += 1

  onSendDelete: =>
    @stats.deletes.sent += 1

  onJoin: =>
    @stats.joins.received += 1

  onGroupDelete: (message) =>
    i = message.index
    worker = @workers.get i
    worker.send { cmd: 'disconnect', body: i }
    @stats.deletes.received += 1
    if @stats.deletes.received == @stats.joins.received
      setTimeout @stop, 1000

  onReceiveUpdate: (message) =>
    @stats.updates.received += 1

  showProgress: =>
    js = @stats.joins.sent
    jr = @stats.joins.received
    us = @stats.updates.sent
    ur = @stats.updates.received
    ds = @stats.deletes.sent
    dr = @stats.deletes.received
    console.log "#{@sessionCount} sessions: joins (#{js} / #{jr}), updates (#{us} / #{ur}), deletes: (#{ds} / #{dr})"

  stop: =>
    @showProgress()
    console.log 'all done'
    @socket.disconnect()
    clearInterval @progressInt
    process.exit()

module.exports = Spy
