boardroomFactory = function(socket, boardInfo) {
  boardroom = {
    max_z: 1,

    dragOptions : function($card) { return {
      onMouseMove: function() {
        socket.emit('move', {_id:$card.id, x:$card.position().left, y:$card.position().top, board_name:boardInfo.name, author:boardInfo.user_id,});
      },
      position: function(dx, dy, x, y, e) {
        var distance = Math.sqrt(dx*dx + dy*dy);
        if (distance < 100) {
          return {left: Math.floor(x - dx*(1-distance/100/5)), top: Math.floor(y - dy*(1-distance/100/5))};
        } else {
          boardroom.group.remove($card);
          $(window).add($card).off('.followDrag');
          $card.mousedown(boardroom.card.onMouseDown)
          boardroom.card.onMouseDownHelper.call($card[0], e.clientX, e.clientY);
          socket.emit('move_commit', {_id:$card.id, x:$card.position().left, y:$card.position().top, board_name:boardInfo.name, author:boardInfo.user_id,});
          return {left: x, top: y};
        }
      },
      onMouseUp: function () {
        
      }
    }},

    moveToTop: function(card) {
      if (parseInt($(card).css('z-index')) === boardroom.max_z) {
        return;
      }
      $(card).css('z-index', ++boardroom.max_z);
    },

    group: {
      addTo: function($card, $targetCard) {
        $card.off('mousedown');
        $card.followDrag(boardroom.dragOptions($card));

        var cardId = $card.attr('id');
        var cardGroupId = $card.data('group-id');
        var targetGroupId = $targetCard.data('group-id');

        if (targetGroupId) {
          boardroom.group.remove($card);

          boardInfo.groups[targetGroupId].cardIds.push(cardId);
          $card.data('group-id', targetGroupId);
          socket.emit('updateGroup', {boardName: boardInfo.name, _id: targetGroupId, cardIds: boardInfo.groups[targetGroupId].cardIds});
          console.log('added ' + targetGroupId);

          boardroom.group.layOut(targetGroupId);
        } else {
          if (cardGroupId) {
            boardInfo.groups[cardGroupId].cardIds.splice(boardInfo.groups[cardGroupId].cardIds.indexOf(cardId), 1);
            socket.emit('updateGroup', {boardName: boardInfo.name, _id: cardGroupId, cardIds: boardInfo.groups[cardGroupId].cardIds});
          }

          socket.emit('createGroup', {boardName: boardInfo.name, cardIds: [$targetCard.attr('id'), cardId]});
          console.log('create');
        }
      },
      remove: function($card) {
        var cardId = $card.attr('id');
        var cardGroupId = $card.data('group-id');
        if (cardGroupId) {
            console.log('removed ' + cardId + ' from ' + cardGroupId);
            boardInfo.groups[cardGroupId].cardIds.splice(boardInfo.groups[cardGroupId].cardIds.indexOf(cardId), 1);
            $card.data('group-id', null);
            socket.emit('updateGroup', {boardName: boardInfo.name, _id: cardGroupId, cardIds: boardInfo.groups[cardGroupId].cardIds});
          }
      },
      onCreated: function(data) {
        console.log('created ' + data._id);

        boardInfo.groups[data._id] = {cardIds: data.cardIds};
        data.cardIds.forEach(function(cardId) {
          $('#' + cardId).data('group-id', data._id);
        })
        boardroom.group.layOut(data._id);
      },
      layOut: function(id) {
        var cardIds = boardInfo.groups[id].cardIds;
        var origin = $('#' + cardIds[0]).offset();
        boardroom.moveToTop($('#' + cardIds[0]));

        cardIds.slice(1).forEach(function(cardId) {
          origin = {
            left: origin.left + 15,
            top:  origin.top  + 36
          };
          $card = $('#' + cardId);
          $card.offset(origin);
          socket.emit('move', {_id:cardId, x:$card[0].offsetLeft, y:$card[0].offsetTop, board_name:boardInfo.name, author:boardInfo.user_id});
          socket.emit('move_commit', {_id:cardId, x:$card[0].offsetLeft, y:$card[0].offsetTop, board_name:boardInfo.name, author:boardInfo.user_id,});
          boardroom.moveToTop($card);
        });
      }
    },

    grouping : function(e) {
      var $activeCard = $(e.target).closest('.card');
      
      var sorted = $('.card').not($activeCard).toArray().sort(function (first,second) {
        return $(second).css('z-index') - $(first).css('z-index');
      });

      sorted.some(function(card) {
        var $card = $(card);
        if ($card.containsPoint(e.pageX, e.pageY)) {
          $activeCard.addClass('group-intent-source');
          $card.addClass('group-intent-target');
          $activeCard.add($card).addClass('group-intent');

          $activeCard.off('.group');
          $activeCard.on('mouseup.group', function() {
            $activeCard.add($card).removeClassMatching(/group-intent.*/g);
            $activeCard.off('.group');
            boardroom.group.addTo($activeCard, $card);
          });

          $activeCard.on('mousemove.group', function(e) {
            if (!$card.containsPoint(e.pageX, e.pageY)) {
              $activeCard.add($card).removeClassMatching(/group-intent.*/g);
              $activeCard.off('.group');
            }
          });
          
          return true; // break out of loop
        }
      });
    },



    card: {
      onMouseDownHelper: function(x, y) {
        var deltaX = x-this.offsetLeft, deltaY = y-this.offsetTop;
        var dragged = this.id, hasMoved = false;
        $card = $(this);

        function location() {
          var card = $('#'+dragged)[0];
          return {_id:dragged, x:card.offsetLeft, y:card.offsetTop, board_name:board.name, author:board.user_id, moved_by:board.user_id};
        }

        var onMousePause = $('.card').onMousePause(boardroom.grouping, 400);

        function mousemove(e) {
          console.log('card mousemove ' + deltaX + " " + deltaY);
          hasMoved = true;
          $('#'+dragged).css('top', e.clientY - deltaY);
          $('#'+dragged).css('left', e.clientX - deltaX);
          socket.emit('move', location() );
        }

        function mouseup(e) {
          onMousePause.off();
          $(window).unbind('mousemove', mousemove);
          $(window).unbind('mouseup', mouseup);
          socket.emit('move_commit', location() );
        }

        $(window).mousemove(mousemove);
        $(window).mouseup(mouseup);
        boardroom.moveToTop(this);
      },
      onMouseDown: function(e) {
        if ($(e.target).is('textarea:focus')) {
          return true;
        }
        boardroom.card.onMouseDownHelper.call(e.target, e.clientX, e.clientY);
      }
    }
  }

  return boardroom;
}