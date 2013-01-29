class boardroom.views.Base extends Backbone.View

  initialize: (attributes) ->
    @$el.data 'view', @
    { @socket } = attributes
    @initializeSourcePath()
    @restingSpot = { left: 0, top: 0 }
    @authorLock = new boardroom.models.CardLock
    @authorLock.poll =>
      @hideNotice()
      @onLockPoll()

  onLockPoll: ()=> # template and hook
  initializeSourcePath: ()->
    throw "initializeSourcePath() not defined!" #template and hook

  ###
      util
  ###
  sourcePath: ()-> throw "sourcPath() not defined!"  # template and hook

  findView: (id) ->
    $("##{id}").data('view')

  enableEditing: (selector)->
    @$(selector).removeAttr 'disabled'

  disableEditing: (selector, text) ->
    @$(selector).val(text).attr('disabled', 'disabled')

  eventsOff: ->
    @$el.off()

  containsPoint: (coordinate) ->
    c = @$el.offset()
    c.left < coordinate.x < (c.left + @$el.width()) and c.top < coordinate.y < (c.top + @$el.height())

  coordinateOfEvent: (e, $container) ->
    coordinate =
      x:0
      y:0
    return coordinate unless e?

    $container = $container.$el if $container?.$el? # if $container is not a jQuery element, assume that it is a view
    $container ||= @$el # default $container to the jQuery element of this view
    { left, top } = $container.offset()

    coordinate.x = Math.round(e.pageX - left) 
    coordinate.y = Math.round(e.pageY - top) 
    coordinate

  coordinateInContainer: ($container) ->
    coordinate =
      x:0
      y:0
    return coordinate unless $container?

    $container = $container.$el if $container.$el? # if $container is not a jQuery element, assume that it is a view
    return coordinate unless $container.offset?()
    { left, top } = $container.offset()

    myOffset = @$el.offset()
    coordinate.x = Math.round(myOffset.left - left) 
    coordinate.y = Math.round(myOffset.top - top) 
    coordinate

  coordinateInBoard: () ->
    boardView = @boardView || $('.board').data('view')
    @coordinateInContainer boardView

  resizeHTML: ()->
    #+++ TODO - this is not working right!
    width =  Math.max ( $(document).width()  ),  ( parseInt $('body').css('min-width') )
    height = Math.max ( -100 + $(document).height() ),  ( parseInt $('body').css('min-height') )
    $('body').width(width) if $('body').width() isnt $(document).width()
    $('body').height(height)

  destroy: () ->
    @eventsOff()
    @unbind()
    @$el.remove()
    @remove()

  ###
      render
  ###

  showNotice: ({ user, message }) =>
    notices = @$('.notice')
    notice = if notices.length == 2 then notices.last() else notices.first() # stupid single-card group hack
    notice
      .html("<img class='avatar' src='#{boardroom.models.User.avatar user}'/><span>#{_.escape message}</span>")
      .show()

  moveTo: ({x, y}) ->    
    if isNaN(Number(x)) or isNaN(Number(y))
      @$el.css {left: x, top: y}
    else # move to x, y but preserve 12px of margin 
      parentOffset = @$el.offsetParent().offset()
      left = x + parentOffset.left
      top = y + parentOffset.top
      @$el.offset { left: left, top: top }
    @resizeHTML()

  addIndicator: ({selector, cssClass, emit}) ->
    return unless cssClass
    $dom = if selector? then @$(selector) else @$el
    $dom.addClass cssClass unless $dom.is cssClass

  removeIndicator: ({selector, cssClass, emit}) ->
    return unless cssClass
    $dom = if selector? then @$(selector) else @$el
    $dom.removeClass cssClass

  hideNotice: ->
    @$('.notice').fadeOut 100

  left: ->
    @$el.position()?.left || 0

  top: ->
    @$el.position()?.top || 0

  right: ->
    @left() + @$el.width()

  bottom: ->
    @top() + @$el.height()

  zIndex: ->
    parseInt(@$el.css('z-index')) || 0

  bringForward: ->
    siblings = @$el.siblings ".#{@className}"
    return if siblings.length == 0

    allZs = _.map siblings, (sibling) ->
      parseInt($(sibling).css('z-index')) || 0
    maxZ = _.max allZs
    return if @zIndex() > maxZ

    newZ = maxZ + 1
    @$el.css 'z-index', newZ
    newZ

  moveBackToRestingSpot: () ->
    @socket.emit "#{@className}.update",
      _id: @model.id
      x: @restingSpot.left # resting spot may use auto (so do not @emitMove())
      y: @restingSpot.top
      author: @model.get('board').get('user_id')
    properties = 
      left: @restingSpot.left
      top: @restingSpot.top
    @$el.css properties

  ###
      services
  ###

  deleteMe: ()->
    @socket.emit "#{@className}.delete", @model.id

  ###
      human interaction event handlers
  ###

  hiDeleteMe: (event)->
    event.stopPropagation()
    @deleteMe()

  ###
      messages
  ###

  emitMove: () ->
    @socket.emit "#{@className}.update",
      _id: @model.id
      x: @left()
      y: @top()
      author: @model.get('board').get('user_id')

  emitAddIndicator: ({selector, cssClass, emit}) ->
    @socket.emit "view.add-indicator",
      _id: @model.id
      selector: selector
      cssClass: cssClass

  emitRemoveIndicator: ({selector, cssClass, emit}) ->
    @socket.emit "view.remove-indicator",
      _id: @model.id
      selector: selector
      cssClass: cssClass


  ###
      debug
  ###

  $debug: ()->
    unless @$debugEl
      e = """
        <div class="debug", style="position:absolute; top:10px; right:10px; border:1px solid black; min-width:100px; min-height:30px;"></div>
      """
      @$el.append(e)
      @$debugEl = @$('.debug')
    @$debugEl

  debugShowMouse: (event)->
    c = @coordinateOfEvent event
    html  = """
      <div>[#{event.pageX}, #{event.pageY}]</div>
      <div>[#{Math.round(event.pageX - @$el.offset().left)}, #{Math.round(event.pageY - @$el.offset().top)}]</div>
      <div>[#{c.x}, #{c.y}]</div>
    """
    @$debug().html html


