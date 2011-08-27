function adjustTextarea(textarea) {
  $(textarea).css('height','auto');
  if ($(textarea).innerHeight() < textarea.scrollHeight) 
    $(textarea).css('height',textarea.scrollHeight);
}

$(function() {
  var socket = io.connect('http://' + document.location.host);
  socket.on( 'move', function( coords ) {
    $('#'+coords.id).css('left', coords.x );
    $('#'+coords.id).css('top', coords.y );
  });
  socket.on( 'add', createCard );
  socket.on( 'text', function( data ) {
    $('#'+data.id+' textarea').val(data.text);
    adjustTextarea($('#'+data.id+' textarea')[0]);
  } );

  function createCard( data ) {
    if ( !data ) {
      data = {
        id: parseInt(Math.random() * 1000000000),
        x: parseInt(Math.random() * ($('.board').innerWidth() - 296)),
        y: parseInt(Math.random() * ($('.board').innerHeight() - 300))
      }
      socket.emit('add', data);
    }

    var $card = $('<div class="card"><textarea style="height: auto; "></textarea></div>')
      .attr('id', data.id)
      .css('left', data.x)
      .css('top', data.y)
    $('.board').append($card);
    $('textarea', $card).focus();
  }

  var dragged;
  $('.card').live('mousedown', function(e) {
    var deltaX = e.clientX-this.offsetLeft, deltaY = e.clientY-this.offsetTop;
    dragged = this.id;

    function move(e) {
      $('#'+dragged).css('top', e.clientY - deltaY);
      $('#'+dragged).css('left', e.clientX - deltaX);
      socket.emit('move', {id:dragged, x:e.clientX - deltaX, y:e.clientY - deltaY});
    }

    $('body').mousemove(move);

    $('body').mouseup(function() {
      $('body').unbind('mousemove', move);
      dragged = null;
    });
  });

  $('.card textarea').live('keyup', function() {
    var card = $(this).closest('.card')[0];
    socket.emit('text', { id:card.id, text:$(this).val() });
    adjustTextarea(this);
    return false;
  });

  $('button.create').click(function() {
    createCard();
  });

  // DEBUG
  window.createCard = createCard;

});
