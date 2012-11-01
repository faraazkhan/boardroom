class boardroom.views.DrawPane extends Backbone.View
  el: '.draw-pane'
  UPDATE_DELAY: 300

  events:
    'mousedown': 'down'
    'mousemove': 'move'
    'mouseup': 'up'
    'mouseleave': 'up'
    'selectstart': -> false

  initialize: (attributes) ->
    { @socket, @drawRenderer, @board } = attributes
    @socket.on 'path.created', @created

  start: ->
    @$el.show()

  stop: ->
    @up() if @stroke
    @$el.hide()

  created: (path) =>
    @id = path._id
    if @stroke.length > 1
      @update()

  update: =>
    @drawRenderer.updatePath {_id:@id, data:@stroke} if @id
    if @updater || ! @id
      return
    else if (new Date().getTime() - @lastUpdate < @UPDATE_DELAY)
      @updater = setTimeout @updateNow(@stroke), @UPDATE_DELAY - (new Date().getTime() - @lastUpdate)
    else
      @updateNow(@stroke)()

  updateNow: (stroke) => =>
    @socket.emit 'path.update', _id:@id, data: stroke
    @lastUpdate = new Date().getTime()
    @updater = null


  down: (e) ->
    @id = null
    @stroke = [[e.offsetX, e.offsetY]]
    @socket.emit 'path.create', boardId:@board.get('_id'), data: @stroke
    @lastUpdate = new Date().getTime()

  up: (e) ->
    if @stroke
      @stroke.push( [e.offsetX, e.offsetY] )
      @update()
      @stroke = null

  move: (e) ->
    if @stroke
      @stroke.push( [e.offsetX, e.offsetY] )
      @update()
