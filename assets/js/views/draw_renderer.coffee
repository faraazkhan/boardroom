class boardroom.views.DrawRenderer extends Backbone.View
  el: '.draw-renderer'
  moveTo: _.template('M <%=x%>,<%=y%>')
  lineTo: _.template('L <%=x%>,<%=y%>')
  endPath:  _.template('z')

  events:
    click: -> false
    dblclick: -> false

  initialize: (attributes) ->
    { @socket, @model } = attributes
    @socket.on 'path.create', @createPath
    @socket.on 'path.update', @updatePath

    @createPath(path) for path in @model.get('paths')

  createPath: (path) =>
    pathElement = document.createElementNS('http://www.w3.org/2000/svg','path')
    pathElement.id = "path-#{path._id}"
    @$el.append pathElement
    @draw pathElement, path.data

  updatePath: (path) =>
    pathElement = @$el.find "#path-#{path._id}"
    @draw pathElement[0], path.data

  draw: (path, stroke) ->
    if ! stroke || stroke.length < 2
      return

    data = _(stroke).map (p)-> x:p[0],y:p[1]
    d = [@moveTo data[0]]
    for point in data.slice(1)
      d.push(@lineTo point)

    path.setAttribute 'd', d.join(' ')

