class boardroom.views.Base extends Backbone.View

  initialize: (attributes) ->
    @$el.data 'view', @
    { @socket } = attributes
    @restingOffset = { left: 0, top: 0 }
    @authorLock = new boardroom.models.CardLock
    @authorLock.poll =>
      @hideNotice()
      @onLockPoll()      

  onLockPoll: ()=>
    # template and hook

  ###
  Convenience
  ###
  findView: (id) ->
    $("##{id}").data('view')

  enableEditing: (selector)->
    @$(selector).removeAttr 'disabled'

  disableEditing: (selector, text) ->
    @$(selector).val(text).attr('disabled', 'disabled')

  eventsOff: ->
    @$el.off 'mousedown'
    @$el.off 'click'
    @$el.off 'dblclick'

  emitMove: () ->
    @socket.emit "#{@className}.update",
      _id: @model.id
      x: @left()
      y: @top()
      author: @model.get('board').get('user_id')

  # xPosition: (item, $target) ->
  #   $target = $(item.target) unless $target?
  #   return 0 unless item? and $target?
  #   x = parseInt (item.pageX - $target.offset().left)
  # yPosition: (item, $target) ->
  #   $target = $(item.target) unless $target?
  #   return 0 unless item? and $target?
  #   y = parseInt (item.pageY - $target.offset().top)

  # eventPositionX: (event) -> (xPosition event, @$el)
  # eventPositionY: (event) -> (yPosition event, @$el)

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
    coordinateInContainer boardView

  ###
  render handlers
  ###
  showNotice: ({ user, message }) =>
    @$('.notice')
      .html("<img class='avatar' src='#{boardroom.models.User.avatar user}'/><span>#{_.escape message}</span>")
      .show()

  moveTo: ({x, y}) ->
    @$el.offset { left: x, top: y }

  hideNotice: ->
    @$('.notice').fadeOut 100

  left: ->
    @$el.offset().left

  top: ->
    @$el.offset().top

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

  ###
  services
  ###
  deleteMe: ()->
    @socket.emit "#{@className}.delete", @model.id

  ###
  human interaction event handlers
  ###
  hiDelete: ()->
    @deleteMe()


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


