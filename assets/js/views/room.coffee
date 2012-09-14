class boardroom.views.Room extends Backbone.View
  initialize: ->
    @socket = io.connect "/boardNamespace/#{@model.get 'name'}"
    @headerView = new boardroom.views.Header
      model: @model
      socket: @socket
    @boardView = new boardroom.views.Board
      model: @model
      socket: @socket

  render: ->
    @headerView.render()
    @boardView.render()
