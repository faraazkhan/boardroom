$('form#enter-board').submit (e) ->
  name = $('input#board-name').val()
  if $.trim(name).length > 0 then document.location = '/boards/' + name
  return false

socketURL = "http://#{document.location.host}/channel/boards"
socket = io.connect socketURL
socket.on 'board_changed', onBoardChanged
socket.on 'card_added', onCardAdded
socket.on 'card_deleted', onCardDeleted
socket.on 'user_activity', userActivity
socket.on 'delete', onDelete

onBoardChanged = (b) -> $("li\##{b._id} .title").html(b.title)

onCardDeleted = (board, user_id) ->
  $count = $("li\##{board._id} span.count")
  $count.html( Math.max(0,parseInt($count.html())-1) )
  userActivity( board, user_id, "Deleted a card" )

onCardAdded = (board, user_id) ->
  $count = $("li\##{board._id} span.count")
  $count.html( parseInt($count.html())+1 )
  userActivity( board, user_id, "Added a card" )

userActivity = (board, user_id, activity) ->
  $activity = $('<img title="' + activity + '" src="/user/avatar/' + encodeURIComponent(user_id) + '"/>');
  $("li\##{board._id} .activity").prepend($activity);
  setTimeout () ->
    $activity.fadeOut 1000, () -> $(this).remove()
  , 10000

onDelete = (board) ->
  $board = $("#\#{board.board_id}")
  $board.height($board.height())
  $board.empty().append($('<p>This board has been deleted.</p>')).delay(2000).slideUp()

$('.delete').click (e) ->
  this.onselectstart = () -> return false
  if $(this).hasClass 'confirm'
    socket.emit 'delete', { board_id: $(this).closest('li').attr('id'), boardName: $(this).closest('li').attr('name') }
    $(this).find('.message').hide()
    $(this).closest('li').slideUp()
  else
    $(this).addClass('confirm')
  return false

$('.delete').mouseleave (e) -> $(this).removeClass('confirm')

