class boardroom.views.Room extends Backbone.View
  initialize: ->
    console.log @model
    @socket = io.connect "/boards/#{@model.get 'sid'}"
    @headerView = new boardroom.views.Header
      model: @model
      socket: @socket
    @boardView = new boardroom.views.Board
      model: @model
      socket: @socket

  render: ->
    @headerView.render()
    @boardView.render()
