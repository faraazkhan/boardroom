class boardroom.views.DrawRenderer extends Backbone.View
  el: '.draw-render'
  moveTo: _.template('M <%=x%>,<%=y%>')
  lineTo: _.template('L <%=x%>,<%=y%>')
  endPath:  _.template('z')

  events:
    click: -> false
    dblclick: -> false

  initialize: ->

  start: (stroke) ->
    @current = document.createElementNS('http://www.w3.org/2000/svg','path')
    @$el.append @current
    @draw stroke

  draw: (stroke) ->    
    if stroke.length < 2
      return

    data = _(stroke).map (p)-> x:p[0],y:p[1]
    d = [@moveTo data[0]]
    for point in data.slice(1)
      d.push(@lineTo point)

    @current.setAttribute 'd', d.join(' ')

  commit: (stroke) ->
    @draw stroke
    @current = null

