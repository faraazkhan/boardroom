class boardroom.views.Base extends Backbone.View

  initialize: (attributes) =>
    super attributes
    @logger = boardroom.utils.Logger.instance
    $.extend(@events, (@touchEvents || {})) if Modernizr.touch

  createDragLock: =>
    onLock = (avatar, message) =>
      @showNotice avatar, message if avatar? and message?
    onUnlock = =>
      @hideNotice()
    new boardroom.models.Lock onLock, onUnlock

  createEditLock: (selector) =>
    onLock = (avatar, message) =>
      console.log 'locking edit ', selector
      @showNotice avatar, message if avatar? and message?
      @disableEditing selector
    onUnlock = =>
      @hideNotice()
      @enableEditing selector
    new boardroom.models.Lock onLock, onUnlock

  enableEditing: (selector) =>
    @$(selector).removeAttr 'disabled'

  disableEditing: (selector) =>
    @$(selector).attr('disabled', 'disabled')

  showNotice: (avatar, message) =>
    notices = @$('.notice')
    @visibleNotice = if notices.length == 2 then notices.last() else notices.first() # stupid single-card group hack
    unless @visibleNotice.is ':visible'
      noticeHTML = """
        <img class='avatar' src='#{avatar}'/><span>#{_.escape message}</span>
      """
      @visibleNotice
        .html(noticeHTML)
        .show()

  hideNotice: =>
    @visibleNotice.fadeOut 100

  moveTo: ({x, y}) =>
    if !x? or !y?
      @$el.css { left: '', top: '' }
    else if isNaN(Number(x)) or isNaN(Number(y))
      @$el.css { left: (x ? ''), top: (y ? '') }
    else
      parentOffset = @$el.offsetParent().offset()
      left = x + parentOffset.left
      top = y + parentOffset.top
      @$el.offset { left: left, top: top }
    @resizeHTML()

  left: =>
    @$el.position()?.left || 0

  top: =>
    @$el.position()?.top || 0

  right: =>
    @left() + @$el.width()

  bottom: =>
    @top() + @$el.height()

  resizeHTML: ()=>
    #+++ TODO - this is not working right!
    width =  Math.max ( $(document).width()  ),  ( parseInt $('body').css('min-width') )
    height = Math.max ( -100 + $(document).height() ),  ( parseInt $('body').css('min-height') )
    $('body').width(width) if $('body').width() isnt $(document).width()
    $('body').height(height)
