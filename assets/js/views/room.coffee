class boardroom.views.Room extends Backbone.View
  initialize: () ->
    @headerView = new boardroom.views.Header
      model: @model
    @boardView = new boardroom.views.Board
      model: @model

  render: ->
    @headerView.render()
    @boardView.render()

