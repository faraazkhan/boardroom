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
  human interaction event handlers
  ###
  hiDelete: ->
    @socket.emit "#{@className}.delete", @model.id
