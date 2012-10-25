class boardroom.views.Room extends Backbone.View
  initialize: ->
    @socket = io.connect "#{@socket_host()}/boards/#{@model.get '_id'}"
    @headerView = new boardroom.views.Header
      model: @model
      socket: @socket
    @boardView = new boardroom.views.Board
      model: @model
      socket: @socket

  render: ->
    @headerView.render()
    @boardView.render()

  # We can dump this when nginx starts supporting websockets
  socket_host: ->
    loc = window.location
    if loc.hostname == 'boardroom.carbonfive.com'
      return 'http://boardroom.carbonfive.com:1337' if loc.port == 80
      return 'http://boardroom.carbonfive.com:1338' if loc.port == 81
    ''
