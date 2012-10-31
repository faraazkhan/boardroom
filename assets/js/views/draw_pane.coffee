class boardroom.views.DrawPane extends Backbone.View
  el: '.draw-pane'

  events:
    'mousedown': 'down'
    'mousemove': 'move'
    'mouseup': 'up'
    'mouseleave': 'up'
    'selectstart': -> false

  initialize: ->
    @stroke
    @renderer = new boardroom.views.DrawRenderer

  start: ->
    @$el.show()

  stop: ->
    @up() if @stroke
    @$el.hide()

  down: (e) ->
    @stroke = []
    @stroke.push( [e.offsetX, e.offsetY] )
    @renderer.start @stroke

  up: (e) ->
    if @stroke
      @stroke.push( [e.offsetX, e.offsetY] )
      @renderer.commit @stroke
      @stroke = null

  move: (e) ->
    if @stroke
      @stroke.push( [e.offsetX, e.offsetY] ) if @stroke
      @renderer.draw @stroke
