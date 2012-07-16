boardroomFactory = function(socket) {
  boardroom = {
    groups: {},

    group: {
      addTo: function($card, $targetCard) {
        var cardId = $card.attr('id');
        var cardGroupId = $card.data('group-id');
        var targetGroupId = $targetCard.data('group-id');
        if (targetGroupId) {
          if (cardGroupId) {
            console.log('removed ' + cardId + ' from ' + cardGroupId);
            boardroom.groups[cardGroupId].splice(boardroom.groups[cardGroupId].indexOf(cardId), 1);
            socket.emit('updateGroup', {_id: cardGroupId, cardIds: boardroom.groups[cardGroupId]});
          }

          boardroom.groups[targetGroupId].push(cardId);
          $card.data('group-id', targetGroupId);
          socket.emit('updateGroup', {_id: targetGroupId, cardIds: boardroom.groups[targetGroupId]});
          console.log('added ' + targetGroupId);

          boardroom.group.layOut(targetGroupId);
        } else {
          if (cardGroupId) {
            boardroom.groups[cardGroupId].splice(boardroom.groups[cardGroupId].indexOf(cardId), 1);
            socket.emit('updateGroup', {_id: cardGroupId, cardIds: boardroom.groups[cardGroupId]});
          }

          socket.emit('createGroup', {cardIds: [$targetCard.attr('id'), cardId]});
          console.log('create');
        }
      },
      onCreated: function(data) {
        console.log('created ' + data._id);

        boardroom.groups[data._id] = data.cardIds;
        data.cardIds.forEach(function(cardId) {
          $('#' + cardId).data('group-id', data._id);
        })
        boardroom.group.layOut(data._id);
      },
      layOut: function(id) {
        var cardIds = boardroom.groups[id];
        var origin = $('#' + cardIds[0]).offset();

        cardIds.slice(1).forEach(function(cardId) {
          origin = {
            left: origin.left + 15,
            top:  origin.top  + 36
          };
          $card = $('#' + cardId);
          $card.offset(origin);
          socket.emit('move_commit', {_id:cardId, x:$card[0].offsetLeft, y:$card[0].offsetTop});
          // moveToTop($(this));
        });
      }
    }
  }

  return boardroom;
}