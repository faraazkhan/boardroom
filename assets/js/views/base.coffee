class boardroom.views.Base extends Backbone.View

  ###
      util
  ###

  initialize: (attributes) ->
    super attributes

  enableEditing: (selector) ->
    @$(selector).removeAttr 'disabled'

  disableEditing: (selector) ->
    @$(selector).attr('disabled', 'disabled')

  resizeHTML: ()->
    #+++ TODO - this is not working right!
    width =  Math.max ( $(document).width()  ),  ( parseInt $('body').css('min-width') )
    height = Math.max ( -100 + $(document).height() ),  ( parseInt $('body').css('min-height') )
    $('body').width(width) if $('body').width() isnt $(document).width()
    $('body').height(height)

  ###
      render
  ###

  showNotice: (user, message) =>
    notices = @$('.notice')
    notice = if notices.length == 2 then notices.last() else notices.first() # stupid single-card group hack
    notice
      .html("<img class='avatar' src='#{boardroom.models.User.avatar user}'/><span>#{_.escape message}</span>")
      .show()

  moveTo: ({x, y}) ->
    if isNaN(Number(x)) or isNaN(Number(y))
      @$el.css {left: (x ? ''), top: (y ? '')}
    else # move to x, y but preserve 12px of margin 
      parentOffset = @$el.offsetParent().offset()
      left = x + parentOffset.left
      top = y + parentOffset.top
      @$el.offset { left: left, top: top }
    @resizeHTML()

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

  rememberRestingSpot: =>
    @model.set 'restingSpot',
      x: @left()
      y: @top()

  moveBackToRestingSpot: =>
    restingSpot = @model.get 'restingSpot'
    @model.set restingSpot
