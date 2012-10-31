class boardroom.views.Draw extends Backbone.View
  el: '#draw'

  events:
    'click': 'toggleDrawMode'

  initialize: (attributes) ->
    @$el.data('drawing',false)
    @drawPane = new boardroom.views.DrawPane

  toggleDrawMode: ->
    drawing = !@$el.data('drawing')
    @$el.data('drawing',drawing)
    if (drawing)
      @drawPane.start()
      @$el.html('Stop Drawing')
    else
      @drawPane.stop()
      @$el.html('Draw')

