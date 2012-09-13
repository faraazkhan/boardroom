class boardroom.views.BoardItem extends Backbone.View
  events:
    'click .delete': 'deleteBoard'

  initialize: ->
    @id = @$el.attr 'id'
    @initializeSocketEventHandlers()

  initializeSocketEventHandlers: ->
    @socket = io.connect '/channel/boards'
    @socket.on 'board_changed', @updateBoardTitle
    @socket.on 'card_added', @increaseBoardCardCount
    @socket.on 'card_deleted', @decreaseBoardCardCount
    @socket.on 'user_activity', @displayUserActivity
    @socket.on 'delete', @removeBoard

  deleteBoard: (event) ->
    event.preventDefault()
    $element = $ event.target
    if $element.hasClass('confirm')
      @socket.emit 'delete',
        board_id: @id
        boardName: @$el.attr('name')
      @$('.message').hide()
      @$el.slideUp()
    else
      $element.addClass('confirm')

  updateBoardTitle: (data) =>
    if data._id is @id
      @$('.title').html(data.title)

  increaseBoardCardCount: (data, user_id) =>
    if data._id is @id
      $count = @$ 'span.count'
      $count.html parseInt($count.html()) + 1
      @displayUserActivity data, user_id, "Added a card"

  decreaseBoardCardCount: (data, user_id) =>
    if data._id is @id
      $count = @$ "li##{data._id} span.count"
      $count.html Math.max(0, parseInt($count.html()) - 1)
      @displayUserActivity data, user_id, "Deleted a card"

  displayUserActivity: (data, user_id, activity) =>
    if data._id is @id
      $activity = $ "<img title='#{activity}' src='#{boardroom.models.User.avatar user_id}'/>"
      @$('.activity').prepend($activity)
      fadeUserActivity = ->
        $activity.fadeOut 1000, ->
          $activity.remove()
      setTimeout fadeUserActivity, 10000

  removeBoard: (data) =>
    if data._id is @id
      $board = $ "##{data.board_id}"
      $board.height $board.height()
      $board
        .empty()
        .append($('<p>This board has been deleted.</p>'))
        .delay(2000)
        .slideUp()
