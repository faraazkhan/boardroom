class boardroom.views.Boards extends Backbone.View
  el: '#boards'

  events:
    'click .delete': 'deleteBoard'

  initialize: ->
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
        board_id: $element.closest('li').attr('id')
        boardName: $element.closest('li').attr('name')
      $element.find('.message').hide()
      $element.closest('li').slideUp()
    else
      $element.addClass('confirm')

  updateBoardTitle: (data) =>
    @$("li##{data._id} .title").html(data.title)

  increaseBoardCardCount: (data, user_id) =>
    console.log data
    $count = @$ "li##{data._id} span.count"
    $count.html parseInt($count.html()) + 1
    @displayUserActivity data, user_id, "Added a card"

  decreaseBoardCardCount: (data, user_id) =>
    $count = @$ "li##{data._id} span.count"
    $count.html Math.max(0, parseInt($count.html()) - 1)
    @displayUserActivity data, user_id, "Deleted a card"

  displayUserActivity: (data, user_id, activity) =>
    $activity = $ "<img title='#{activity}' src='#{boardroom.models.User.avatar user_id}'/>"
    @$("li##{data._id} .activity").prepend($activity)
    setTimeout ->
      $activity.fadeOut 1000, -> $activity.remove()
    , 10000

  removeBoard: (data) ->
    $board = $ "##{data.board_id}"
    $board.height $board.height()
    $board
      .empty()
      .append($('<p>This board has been deleted.</p>'))
      .delay(2000)
      .slideUp()
