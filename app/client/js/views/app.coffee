class boardroom.views.App extends Backbone.View
  initialize: (attributes) ->
    @board = new boardroom.models.Board attributes.board
    @socket = new boardroom.models.Socket
      board: @board
    @headerView = new boardroom.views.Header
      model: @board
      socket: @socket
    @boardView = new boardroom.views.Board
      model: @board
      socket: @socket

  render: ->
    @headerView.render()
    @boardView.render()
