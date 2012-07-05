$(function() {

  $('form#enter-board').submit(function(e) {
    var name = $('input#board-name').val();
    if ($.trim(name).length > 0) {
      document.location = '/boards/' + name;
    }
    return false;
  });

  var socketURL =  'http://' + document.location.host + '/channel/boards';
  var socket = io.connect(socketURL);
  socket.on( 'board_changed', onBoardChanged );
  socket.on( 'card_added', onCardAdded );
  socket.on( 'card_deleted', onCardDeleted );
  socket.on( 'user_activity', userActivity );
  socket.on( 'delete', onDelete );

  function onBoardChanged( b ) {
    $('li#' + b._id + ' .title').html(b.title);
  }

  function onCardDeleted( board, user_id ) {
    var $count = $('li#' + board._id + ' span.count');
    $count.html( Math.max(0,parseInt($count.html())-1) );
    userActivity( board, user_id, "Deleted a card" );
  }

  function onCardAdded( board, user_id ) {
    var $count = $('li#' + board._id + ' span.count');
    $count.html( parseInt($count.html())+1 );
    userActivity( board, user_id, "Added a card" );
  }

  function userActivity( board, user_id, activity ) {
    var $activity = $('<img title="' + activity + '" src="/user/avatar/' + encodeURIComponent(user_id) + '"/>');
    $('li#' + board._id + ' .activity').prepend($activity);
    setTimeout(function() {
      $activity.fadeOut(1000, function() { $(this).remove(); });
    }, 10000);
  }

  function onDelete ( board ) {
    $board = $('#' + board.board_id);
    $board.height($board.height());
    $board.empty().append($('<p>This board has been deleted.</p>')).delay(2000).slideUp();
  }

  $('.delete').click(function(e) {
    this.onselectstart = function () { return false; }
    if ($(this).hasClass('confirm')) {
      socket.emit('delete', { board_id: $(this).closest('li').attr('id') });
      $(this).closest('li').slideUp();
    } else {
      $(this).addClass('confirm');
    }
    return false;
    // $(this).closest('li').empty().append('<a style="padding-top: 0.5em; padding-bottom: 0.5em">Deleted.</a><div class="actions" style="display:block;"><div>Undo</div></div>');
  });

  $('.delete').mouseleave(function(e) {
    $(this).removeClass('confirm');
  });

});
