class boardroom.views.DrawButton extends Backbone.View
  el: '#draw'

  events:
    'click': 'toggleDrawMode'

  initialize: (attributes) ->
    { @drawPane } = attributes
    @$el.data('drawing',false)

  toggleDrawMode: ->
    drawing = !@$el.data('drawing')
    @$el.data('drawing',drawing)
    if (drawing)
      @drawPane.start()
      @$el.html('Stop Drawing')
    else
      @drawPane.stop()
      @$el.html('Draw')

